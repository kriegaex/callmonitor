## fifo-based notification
wait_fifo() {
    local fifo=$1
    [ ! -p "$fifo" ] && return
    exec 3>&2 2>/dev/null
    < "$fifo"
    exec 2>&3 3>&-
}

notifyall_fifo() {
    local fifo=$1
    [ ! -p "$fifo" ] && return
    rm -f "$fifo" 3> "$fifo"
}
