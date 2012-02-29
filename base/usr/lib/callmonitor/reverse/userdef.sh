_reverse_userdef_url() {
    URL=""
}
_reverse_userdef_request() {
    if [ ! -x "$CALLMONITOR_REVERSE_USERDEF" ]; then
	return 2
    fi
    local output status
    output=$("$CALLMONITOR_REVERSE_USERDEF" "$1"); status=$?
    case $status in
	0) echo "OK:$output" ;;
	1) echo "NA:" ;;
    esac
    return $status
}
_reverse_userdef_extract() {
    head -n 1
}
