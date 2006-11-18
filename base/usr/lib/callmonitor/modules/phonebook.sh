##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##
require net
require lock
require util
require reverse
require file
require usage

normalize_address() {
    local number=$1
    case $number in
	SIP*|*@*) normalize_sip "$@" ;;
	*) normalize_tel "$@" ;;
    esac
}

## normalize phone numbers
normalize_tel() {
    local number=$1 mode=$2
    ## Call by call
    case $number in
	010[1-9]?*) number=${number#010[1-9]?} ;;
	0100??*) number=${number#0100??} ;;
    esac
    ## Country prefix of Germany
    case $number in
	0049*) number=0${number#0049} ;;
	49*) if ? "${#number} > 10"; then number=0${number#49}; fi ;;
    esac
    ## Local number
    if [ "$mode" != display ]; then
	case $number in
	    [1-9]*) number=${CALLMONITOR_OKZ}${number} ;; 
	esac
    fi
    __=$number
}

## transform SIP[0-9] into SIP addresses
normalize_sip() {
    local number=$1
    case $number in
	SIP[0-9])
	    if eval "? \"\${${number}_address+1}\""; then
		eval "number=\"\$${number}_address\""
	    fi
	    ;;
    esac
    __=$number
}
## read SIP[0-9] to address mapping
if [ -r /var/run/phonebook/sip ]; then
    . /var/run/phonebook/sip
fi

## Options to be overwritten before call of phonebook functions
_pb_REVERSE=false
case $CALLMONITOR_REVERSE in
    yes) _pb_REVERSE=true ;;
    no)  _pb_REVERSE=false ;;
esac

## Required functions
_pb_debug() { true; }

## Constant options set from config file
_pb_CACHE=true _pb_PERSISTENT=false 
case $CALLMONITOR_REVERSE_CACHE in
    no)  _pb_CACHE=false _pb_PERSISTENT=false ;;
    transient)	_pb_CACHE=true _pb_PERSISTENT=false ;;
    persistent) _pb_CACHE=true _pb_PERSISTENT=true ;;
esac
## where to put new number-name pairs
if $_pb_PERSISTENT; then
    _pb_PHONEBOOK=$CALLMONITOR_PERSISTENT
else
    _pb_PHONEBOOK=$CALLMONITOR_TRANSIENT
fi
ensure_file "$CALLMONITOR_TRANSIENT" "$CALLMONITOR_PERSISTENT"

_pb_get() {
    local number=$1 number_norm name exitval __
    _pb_get_local "$number"
    exitval=$?; name=$__
    if ? "exitval != 0"; then
	normalize_address "$number"; number_norm=$__
	if [ "$number_norm" != "$number" ]; then
	    _pb_get_local "$number_norm"
	    exitval=$?; name=$__
	fi
	if ? "exitval != 0" && $_pb_REVERSE; then
	    name=$(reverse_lookup "$number_norm")
	    if ? $? == 0 && $_pb_CACHE; then
		_pb_put_local "$number_norm" "$name" >&2 &
		exitval=0
	    fi
	fi
    fi
    echo "$name"
    return $exitval
}

## for performance, _pb_get_local returns its result in $__
_pb_get_local() {
    local number=$1 name
    if _pb_find_number < "$CALLMONITOR_PERSISTENT" ||
	_pb_find_number < "$CALLMONITOR_TRANSIENT"
    then
	_pb_debug "phone book contains {$number -> $name}"
	__=$name
	return 0
    fi
    __=
    return 1
}
_pb_find_number() {
    local nu na
    while read -r nu na; do
	if [ "$nu" = "$number" ]; then name=$na; return 0; fi
    done
    return 1
}

_pb_remove() {
    MODE=remove _pb_put_or_remove "$@"
}
_pb_put_local() {
    MODE=put _pb_put_or_remove "$@"
}
_pb_put_or_remove() {
    local number=$1 name=$2 __
    local number_re=$(sed_re_escape "$number")
    case $MODE in 
	remove)
	    _pb_debug "removing $number from phone book $_pb_PHONEBOOK" ;;
	*)
	    _pb_norm_value "$name"; name=$__
	    _pb_debug "putting {$number -> $name} into phone book $_pb_PHONEBOOK"
	;;
    esac

    ## beware of concurrent updates
    if lock "$_pb_PHONEBOOK"; then
	local tmpfile=$CALLMONITOR_TMPDIR/.callmonitor.tmp
	{ 
	    sed -e "/^${number_re}[[:space:]]/d" "$_pb_PHONEBOOK" 2> /dev/null
	    case $MODE in put)
		echo "${number}	${name}" ;;
	    esac
	} > "$tmpfile"
	mv "$tmpfile" "$_pb_PHONEBOOK"
	unlock "$_pb_PHONEBOOK"
    else
	_pb_debug "locking $_pb_PHONEBOOK failed"
    fi
    if $_pb_PERSISTENT; then
	callmonitor_store
    fi
}
## a value must always be a single line (we normalize whitespace as we go)
_pb_norm_value() {
    __=$(echo $(echo "$@" | sed -e '$!s/$/;/'))
}

_pb_init() {
    local run="/var/run/phonebook"
    mkdir -p "$run"
    "$CALLMONITOR_LIBDIR/sipnames" > "$run"/sip
}

_pb_tidy() {
    local exitval=1
    local book=$CALLMONITOR_PERSISTENT
    echo -n "Tidying up $book: " >&2
    if lock "$book"; then
	echo -n "sorting and cleansing, " >&2
	local tmpfile=$CALLMONITOR_TMPDIR/.callmonitor.tmp
	sort -u "$book" | 
	sed -e '
	    /^[[:space:]]*$/d
	    s/^[[:space:]]*//
	    s/[[:space:]]\+/	/
	' > "$tmpfile" && mv "$tmpfile" "$book"
	exitval=$?
	rm -f "$tmpfile"
	unlock "$book"
    fi
    if ? exitval == 0 && $_pb_PERSISTENT; then
	callmonitor_store
    fi
    if ? exitval == 0; then
	echo "done." >&2
    else
	echo "failed." >&2
    fi
}

_pb_list() {
    case $1 in
	all) cat "$CALLMONITOR_PERSISTENT" "$CALLMONITOR_TRANSIENT" 2>/dev/null ;;
	*)   cat "$CALLMONITOR_PERSISTENT" 2>/dev/null ;;
    esac
}

_pb_main() {
    local _pb_REVERSE
    for arg; do
	case $arg in
	    --local) _pb_REVERSE=false; shift ;;
	    --) shift; break ;;
	esac
    done
    case $1 in
	get) _pb_get "$2" ;;
	exists) _pb_get "$2" > /dev/null ;;
	remove) _pb_remove "$2" ;;
	put) _pb_put_local "$2" "$3" ;;
	init) _pb_init ;;
	tidy) _pb_tidy ;;
	list) _pb_list "$2" ;;
	*) usage >&2; exit 1 ;;
    esac
    return $?
}

