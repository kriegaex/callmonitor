require reverse

list_providers() {
    local type provider countries site label
    while readx type provider countries site label; do
	printf "%-15s %-7s %s\n" $provider "${countries%!}" "$label"
    done < "$CALLMONITOR_REVERSE_CFG"
}

lookup() {
    local query=$1
    normalize_address "$query" || return 1
    local number=$__
    empty "$number" && return 1

    local prov=$PROV
    if [ -z "$prov" ]; then
        _reverse_choose_provider "$number"
    else
	_reverse_require_provider "$prov"
    fi
    $VERBOSE && echo    "Number:   $number"
    $VERBOSE && echo    "Provider: $prov"

    $VERBOSE && echo -n "Result:   "
    local result
    result=$(_reverse_lookup "$prov" "$number")
    local status=$?
    echo "$result"

    if $VERBOSE; then
	echo -n "Status:   $status "
	case $status in
	    0) echo "(ok)" ;;
	    1) echo "(not available)" ;;
	    2) echo "(error)" ;;
	    *) echo ;;
	esac
    fi
    $VERBOSE && echo
    return $status
}

unset PROV
VERBOSE=false

opts=$(getopt -o lv -n "$APPLET" -- "$@") || exit 1
eval "set -- $opts"

while true; do
    case $1 in
	-l) list_providers; exit ;;
	-v) VERBOSE=true; shift ;;
	--) shift; break ;;
    esac
done

for arg; do
    case $arg in 
	@*) PROV=${arg#@} ;;
    esac
done

if [ -n "$PROV" ]; then
    _reverse_load "$PROV"
fi

for arg; do
    case $arg in
	@*) ;;
	*) lookup "$arg" ;;
    esac
done
