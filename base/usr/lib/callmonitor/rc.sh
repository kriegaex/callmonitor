check_status() {
    local exitval="${1:-$?}"
    if [ "$exitval" -eq 0 ]; then
	echo "done."
    else
	echo "failed."
    fi
    return $exitval
}
