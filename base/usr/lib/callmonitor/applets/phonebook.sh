require phonebook
require usage
## requires /usr/lib/callmonitor/usage/phonebook.sh

## format of phone book: ${NUMBER}<whitespace>${NAME}

## parse options
_pb_DEBUG=false
TEMP=$(getopt -o '' -l debug,local,help,persistent -n "${0##*/}" -- "$@") || exit 1
eval "set -- $TEMP"

while true; do
    case $1 in
	--local) _pb_REVERSE=false ;;
	--debug) _pb_DEBUG=true ;;
	--persistent) _pb_PERSISTENT=true ;;
	--help) usage >&2; exit 1 ;;
	--) shift; break ;;
	*) ;; # should never happen
    esac
    shift
done

## set up logging
if $_pb_DEBUG; then
    _pb_debug() { echo "phonebook: $*" >&2; }
    _pb_debug "entering DEBUG mode"
fi

## check syntax: number of arguments (to phonebook) expected
check=1
case $1 in
    put) check="$# == 3" ;;
    get|exists|remove|rm) check="$# == 2" ;;
    init|start|tidy|flush) check="$# == 1" ;;
    list|ls) check="$# >= 1 && $# <= 2" ;;
    *) check= ;;
esac
if ! ? "$check"; then
    usage >&2
    exit 1
fi

_pb_main -- "$@"
exit $?
