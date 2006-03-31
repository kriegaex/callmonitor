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

## format of phone book: ${CALLMONITOR_PREFIX}${NUMBER}${CALLMONITOR_SEPARATOR}${NAME}

## parse options
_pb_DEBUG=false
TEMP="$(getopt -o '' -l debug,local,help -n "${0##*/}" -- "$@")" || exit 1
eval "set -- $TEMP"

while true; do
    case $1 in
	--local) _pb_REVERSE=false ;;
	--debug) _pb_DEBUG=true ;;
	--help) _usage >&2; exit 1 ;;
	--) shift; break ;;
	*) ;; # should never happen
    esac
    shift
done

## set up logging
if $_pb_DEBUG; then
    __debug() { echo "phonebook: $*" >&2; }
    __debug "entering DEBUG mode"
fi

## check syntax:
## number of arguments (to phonebook) expected
expect=0
case $1 in
    put) expect=3 ;;
    get|exists|remove) expect=2 ;;
    init|tidy) expect=1 ;;
    *) expect=0 ;;
esac
if ? "$# != expect"; then
    _usage >&2
    exit 1
fi

_pb_main -- "$@"
exit $?
