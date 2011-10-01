## generic option parsing
_getopt() {
    local - temp consumed name=$1 ERROR=0
    shift
    temp=$(_getopt_$name "$@") || return 1
    set -f; eval "set -- $temp"; set +f
    while true; do
	_opt_$name "$@"; consumed=$?
	if ? "ERROR > 0"; then
	    return $ERROR
	fi
	if ? "consumed > 0"; then
	    shift $consumed
	else
	    case $1 in
		--) shift; break ;;
		*) echo "$name: unrecognized option \`$1'"; return 1 ;;
	    esac
	fi
    done
    _body_$name "$@"
}
