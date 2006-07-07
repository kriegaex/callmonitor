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

normalize_address() {
    local NUMBER="$1"
    case "$NUMBER" in
	SIP*) normalize_sip "$NUMBER" ;;
	*)    normalize_tel "$NUMBER" ;;
    esac
}

## normalize phone numbers
normalize_tel() {
    local NUMBER="$1"
    # Call by call
    case $NUMBER in
	010[1-9]?*) NUMBER="${NUMBER#010[1-9]?}" ;;
	0100??*) NUMBER="${NUMBER#0100??}" ;;
    esac
    # Country prefix of Germany
    case $NUMBER in
	0049*) NUMBER="0${NUMBER#0049}" ;;
	49*) if ? "${#NUMBER} > 10"; then NUMBER="0${NUMBER#49}"; fi ;;
    esac
    # Local number
    case $NUMBER in
	[1-9]*) NUMBER="${CALLMONITOR_OKZ}${NUMBER}" ;; 
    esac
    __="$NUMBER"
}

## transform SIP[0-9] into SIP addresses
normalize_sip() {
    local NUMBER="$1"
    case "$NUMBER" in
	SIP[0-9])
	    if eval "? \"\${${NUMBER}_address+1}\""; then
		eval "NUMBER=\"\$${NUMBER}_address\""
	    fi
	    ;;
    esac
    __="$NUMBER"
}
## read SIP[0-9] to address mapping
if < /var/run/phonebook/sip; then
    . /var/run/phonebook/sip
fi

## Options to be overwritten before call of phonebook functions
_pb_REVERSE=false
case "$CALLMONITOR_REVERSE" in
    yes) _pb_REVERSE=true ;;
    no)  _pb_REVERSE=false ;;
esac

## Required functions
_pb_debug() { true; }

## Constant options set from config file
_pb_CACHE=true _pb_PERSISTENT=false 
case "$CALLMONITOR_REVERSE_CACHE" in
    no)  _pb_CACHE=false _pb_PERSISTENT=false ;;
    transient)	_pb_CACHE=true _pb_PERSISTENT=false ;;
    persistent) _pb_CACHE=true _pb_PERSISTENT=true ;;
esac
## where to put new number-name pairs
if $_pb_PERSISTENT; then
    _pb_PHONEBOOK="$CALLMONITOR_PERSISTENT"
else
    _pb_PHONEBOOK="$CALLMONITOR_TRANSIENT"
fi
touch "$CALLMONITOR_TRANSIENT"

_pb_get() {
    local NUMBER="$1" NUMBER_NORM NAME exitval
    _pb_get_local "$NUMBER"
    exitval=$?; NAME=$__
    if ? "exitval != 0"; then
	normalize_address "$NUMBER"; NUMBER_NORM=$__
	case $NUMBER_NORM in "$NUMBER") ;; *)
	    _pb_get_local "$NUMBER_NORM"
	    exitval=$?; NAME=$__
	;; esac
	if ? "exitval != 0" && $_pb_REVERSE; then
	    NAME="$(reverse_lookup "$NUMBER_NORM")"
	    if ? $? == 0 && $_pb_CACHE; then
		_pb_put_local "$NUMBER_NORM" "$NAME" >&2 &
		exitval=0
	    fi
	fi
    fi
    echo "$NAME"
    return $exitval
}

## for performance, _pb_get_local returns its result in $__
_pb_get_local() {
    local NUMBER="$1" NUMBER_RE NAME num nam
    unset NAME
    while read -r num nam; do
	case $num in "$NUMBER") NAME=$nam; break ;; esac
    done < "$CALLMONITOR_PERSISTENT"
    if ! ? "${NAME+1}"; then
	while read -r num nam; do
	    case $num in "$NUMBER") NAME=$nam; break ;; esac
	done < "$CALLMONITOR_TRANSIENT"
    fi
    if ? "${NAME+1}"; then
	#NAME="${NAME#:}"
	_pb_debug "phone book contains {$NUMBER -> $NAME}"
	__=$NAME
	return 0
    fi
    __=$NAME
    return 1
}

_pb_remove() {
    MODE=remove _pb_put_or_remove "$@"
}
_pb_put_local() {
    MODE=put _pb_put_or_remove "$@"
}
_pb_put_or_remove() {
    local NUMBER="$1" NAME="$2" NUMBER_RE
    NUMBER_RE="$(sed_re_escape "$NUMBER")"
    case $MODE in 
	remove)
	    _pb_debug "removing $NUMBER from phone book $_pb_PHONEBOOK" ;;
	*)
	    _pb_norm_value "$NAME"; NAME=$__
	    _pb_debug "putting {$NUMBER -> $NAME} into phone book $_pb_PHONEBOOK"
	;;
    esac

    ## beware of concurrent updates
    if lock "$_pb_PHONEBOOK"; then
	local TMPFILE="$CALLMONITOR_TMPDIR/.callmonitor.tmp"
	{ 
	    sed -e "/^${NUMBER_RE}[[:space:]]/d" "$_pb_PHONEBOOK" 2> /dev/null
	    case $MODE in put)
		echo "${NUMBER}	${NAME}" ;;
	    esac
	} > "$TMPFILE"
	mv "$TMPFILE" "$_pb_PHONEBOOK"
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
    RUN="/var/run/phonebook"
    mkdir -p "$RUN"
    "$CALLMONITOR_LIBDIR/sipnames" > "$RUN"/sip
}

_pb_tidy() {
    local exitval=1
    local book="$CALLMONITOR_PERSISTENT"
    echo -n "Tidying up $book: " >&2
    if lock "$book"; then
	echo -n "sorting and cleansing, " >&2
	local TMPFILE="$CALLMONITOR_TMPDIR/.callmonitor.tmp"
	sort -u "$book" | 
	sed -e '
	    /^[[:space:]]*$/d
	    s/^[[:space:]]*//
	    s/[[:space:]]\+/	/
	' > "$TMPFILE" && mv "$TMPFILE" "$book"
	exitval=$?
	rm -f "$TMPFILE"
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
	*) _usage >&2; exit 1 ;;
    esac
    return $?
}

