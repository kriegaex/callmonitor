## start or stop ssh daemon
RC_DROPBEAR="/mod/etc/init.d/rc.dropbear"
droptoggle() {
	if [ -x "$RC_DROPBEAR" ]; then
		if [ "$("$RC_DROPBEAR" status)" = "running" ]; then
			"$RC_DROPBEAR" stop
		else
			"$RC_DROPBEAR" start
		fi
	fi
}

## start ssh daemon
dropon() {
	if [ -x "$RC_DROPBEAR" ]; then
		"$RC_DROPBEAR" start
	fi
}

## stop ssh daemon
dropoff() {
	if [ -x "$RC_DROPBEAR" ]; then
		"$RC_DROPBEAR" stop
	fi
}
