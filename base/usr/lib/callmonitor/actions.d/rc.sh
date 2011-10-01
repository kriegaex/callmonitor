rc() {
    local service=$1; shift
    local dir rc
    for dir in /mod/etc/init.d /etc/init.d ""; do
	[ "$dir" == "" ] && return 1
	rc="$dir/rc.$service"
	[ -x "$rc" ] && break
    done
    if [ "$#" -eq 0 ]; then
	echo "$rc"
	return
    fi
    local cmd=$1; shift
    case $cmd in
    	toggle)
	    case $("$rc" status) in
	    	running) "$rc" stop ;;
		stopped) "$rc" start ;;
	    esac
	    ;;
	*)
	    "$rc" "$cmd" "$@"
	    ;;
    esac
}

## start or stop ssh daemon
droptoggle() {
    rc dropbear toggle
}

## start ssh daemon
dropon() {
    rc dropbear start
}

## stop ssh daemon
dropoff() {
    rc dropbear stop
}
