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
_usage() {
#<
    cat <<END
Usage:	phonebook [option]... command [argument]...
	phonebook {get|exists|remove} 053712931
	phonebook put 0357937829 "John Smith"
	phonebook init # prepare SIP to name mapping
	phonebook tidy # tidy up phonebook (sort)
Options:
    --local  suppress reverse lookup
    --debug  enable extra debugging output
    --help   show this help and exit
END
#>
}

require phonebook
require lock
require util

## format of phone book: ${PRE}${NUMBER}${SEP}${NAME}
PRE="$CALLMONITOR_PREFIX"
PRE_RE="$CALLMONITOR_PREFIX_RE"
SEP="$CALLMONITOR_SEPARATOR"
SEP_RE="$CALLMONITOR_SEPARATOR_RE"

REVERSE=false CACHE=true PERSISTENT=false DEBUG=false
case "$CALLMONITOR_REVERSE" in
    yes) REVERSE=true ;;
    no)  REVERSE=false ;;
esac
case "$CALLMONITOR_REVERSE_CACHE" in
    no)  CACHE=false PERSISTENT=false ;;
    transient)	CACHE=true PERSISTENT=false ;;
    persistent) CACHE=true PERSISTENT=true ;;
esac

## parse options
TEMP="$(getopt -o '' -l debug,local,help -n "${0##*/}" -- "$@")" || exit 1
eval "set -- $TEMP"

while true; do
    case $1 in
	--local) REVERSE=false ;;
	--debug) DEBUG=true ;;
	--help) _usage >&2; exit 1 ;;
	--) shift; break ;;
	*) ;; # should never happen
    esac
    shift
done

## where to put new number-name pairs
if $PERSISTENT; then
    PHONEBOOK="$CALLMONITOR_PERSISTENT"
else
    PHONEBOOK="$CALLMONITOR_TRANSIENT"
fi

## set up logging
if $DEBUG; then
    __debug() { echo "phonebook: $*" >&2; }
    __debug "entering DEBUG mode"
else
    __debug() { true; }
fi

_get() {
    local NUMBER="$1" NUMBER_NORM NAME exitval
    NAME="$(_get_local "$NUMBER")"
    exitval=$?
    if [ $exitval -ne 0 ]; then
	NUMBER_NORM="$(normalize_address "$NUMBER")"
	if [ "$NUMBER_NORM" != "$NUMBER" ]; then
	    NAME="$(_get_local "$NUMBER_NORM")"
	    exitval=$?
	fi
	if [ $exitval -ne 0 ] && $REVERSE; then
	    NAME="$(reverse_lookup "$NUMBER_NORM")"
	    if [ $? -eq 0 ] && $CACHE; then
		_put_local "$NUMBER_NORM" "$NAME" >&2 &
		exitval=0
	    fi
	fi
    fi
    echo "$NAME"
    return $exitval
}

_get_local() {
    local NUMBER="$1" NAME NUMBER_RE
    NUMBER_RE="$(echo "$NUMBER" | sed_re_escape)"
    NAME="$(sed -ne "/^${PRE_RE}${NUMBER_RE}${SEP_RE}/{
	s/^${PRE_RE}${NUMBER}${SEP_RE}/:/p;q}" \
	"$CALLMONITOR_TRANSIENT" "$CALLMONITOR_PERSISTENT" 2> /dev/null)"
    if [ ! -z "$NAME" ]; then
	NAME="${NAME#:}"
	__debug "phone book contains {$NUMBER -> $NAME}"
	echo "$NAME"
	return 0
    fi
    return 1
}

_remove() {
    MODE=remove _put_or_remove "$@"
}
_put_local() {
    MODE=put _put_or_remove "$@"
}
_put_or_remove() {
    local NUMBER="$1" NAME="$2" NUMBER_RE
    NUMBER_RE="$(echo "$NUMBER" | sed_re_escape)"
    if [ "$MODE" = "remove" ]; then
	__debug "removing $NUMBER from phone book $PHONEBOOK"
    else
	NAME="$(_norm_value "$NAME")"
	__debug "putting {$NUMBER -> $NAME} into phone book $PHONEBOOK"
    fi

    ## beware of concurrent updates
    if lock "$PHONEBOOK"; then
	local TMPFILE="$CALLMONITOR_TMPDIR/.callmonitor.tmp"
	{ 
	    if [ -e "$PHONEBOOK" ]; then
		sed -e "/^${PRE_RE}${NUMBER_RE}${SEP_RE}/d" "$PHONEBOOK"
	    fi
	    if [ "$MODE" = "put" ]; then
		echo "${PRE}${NUMBER}${SEP}${NAME}"
	    fi
	} > "$TMPFILE"
	cat "$TMPFILE" > "$PHONEBOOK"
	rm "$TMPFILE"
	unlock "$PHONEBOOK"
    else
	__debug "locking $PHONEBOOK failed"
    fi
    if $PERSISTENT; then
	callmonitor_store
    fi
}
## a value must always be a single line (we normalize whitespace as we go)
_norm_value() {
    echo $(echo "$@" | sed -e 's/$/;/')
}

_init() {
    RUN="/var/run/phonebook"
    if [ ! -d "$RUN" ]; then
	mkdir -p "$RUN"
    fi
    "$CALLMONITOR_LIBDIR/sipnames" > "$RUN"/sip
}

_tidy() {
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
	' > "$TMPFILE" && cat "$TMPFILE" > "$book"
	exitval=$?
	rm "$TMPFILE"
	unlock "$book"
    fi
    if [ $exitval -eq 0 ] && $PERSISTENT; then
	callmonitor_store
    fi
    if [ $exitval -eq 0 ]; then
	echo "done." >&2
    else
	echo "failed." >&2
    fi
}

## check syntax:
## number of arguments (to phonebook) expected
expect=0
case $1 in
    put) expect=3 ;;
    get|exists|remove) expect=2 ;;
    init|tidy) expect=1 ;;
    *) expect=0 ;;
esac
if [ $# -ne $expect ]; then
    _usage >&2
    exit 1
fi

case $1 in
    get) _get "$2" ;;
    exists) _get "$2" > /dev/null ;;
    remove) _remove "$2" ;;
    put) _put_local "$2" "$3" ;;
    init) _init ;;
    tidy) _tidy ;;
    *) _usage >&2; exit 1 ;;
esac
exit $?
