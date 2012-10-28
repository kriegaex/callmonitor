require reverse

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
    echo "number=$number, prov=$prov" >&2

    _reverse_lookup "$prov" "$number"
    local status=$?

    echo "status=$status" >&2
    return $status
}

unset PROV

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
