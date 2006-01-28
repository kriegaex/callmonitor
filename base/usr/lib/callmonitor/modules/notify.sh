## fifo-based notification
waitfifo() {
    local fifo=$1
    [ ! -p "$fifo" ] && return
    exec 3>&2 2>/dev/null
    < "$fifo"
    exec 2>&3 3>&-
}

notifyfifo() {
    local fifo=$1
    [ ! -p "$fifo" ] && return
    rm -f "$fifo" 3> "$fifo"
}
