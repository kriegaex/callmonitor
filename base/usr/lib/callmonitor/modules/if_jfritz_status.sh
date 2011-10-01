require dial

_j_is_up() {
    busybox nc "$CALLMONITOR_MON_HOST" "$CALLMONITOR_MON_PORT" < /dev/null > /dev/null 2>&1
}

_j_dial() {
    case $CALLMONITOR_MON_HOST in
	localhost|127.*|"") ;;
	*) echo "Cannot $2 interface of remote box; please dial $1 manually."; return 1 ;;
    esac
    case $CALLMONITOR_MON_PORT in
	1012) dial "$1" ;;
	*) echo "Cannot $2 interface at non-standard port."; return 1 ;;
    esac
}
_j_enable() {
    _j_dial "#96*5*" enable
}

_j_disable() {
    _j_dial "#96*4*" disable
}
