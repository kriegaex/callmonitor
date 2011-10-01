check_status() {
    local exitval=${1:-$?}
    if ? exitval == 0; then
	echo "done."
    else
	echo "failed."
    fi
    return $exitval
}
