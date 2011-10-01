usage() {
    local cmd=${1:-${0##*/}}
    local usage="$CALLMONITOR_LIBDIR/usage/$cmd.sh"
    if [ -r "$usage" ]; then
	. "$usage"
    fi
}
