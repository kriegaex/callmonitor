DAEMON=callmonitor
TELEFON="$CALLMONITOR_LIBDIR/telefon"
FIFO="/var/run/$DAEMON/fifo"

if [ ! -d /var/run/$DAEMON ]; then
	mkdir -p /var/run/$DAEMON
fi

check_status() {
	local exitval="${1:-$?}"
	if [ "$exitval" -eq 0 ]; then
		echo "done."
	else
		echo "failed."
	fi
	return $exitval
}

start_telefon() {
	echo -n "Starting telefon..."
	"$TELEFON" < /dev/null 1>&3 3>&- 2> /dev/null
	check_status
}
stop_telefon() {
	echo -n "Stopping telefon..."
	killall telefon > /dev/null 2>&1
	check_status
}

start_daemon() {
	if [ ! -e /mod/etc/callmonitor.listeners ]; then
		ln -sf "$CALLMONITOR_LISTENERS" /mod/etc/callmonitor.listeners
	fi

	echo -n "Starting callmonitor..."
	"$DAEMON" > /dev/null 2>&1
	check_status
}
stop_daemon() {
	echo -n "Stopping callmonitor..."
	"$DAEMON" -s
	check_status
}
