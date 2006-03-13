##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##
DAEMON=callmonitor

## we need the telefon package
if ! has_package telefon; then
    echo "Fatal error: Package 'telefon' is missing" >&2
    exit 1
fi

require rc
require modreg

FIFO="$CALLMONITOR_FIFO"
FIFO_DIR="${FIFO%/*}"
if [ ! -d "$FIFO_DIR" ]; then
    mkdir -p "$FIFO_DIR"
fi
PIDFILE="$CALLMONITOR_VAR/pid"

case "$1" in
    ""|load|start|restart)
	if [ ! -r "$CALLMONITOR_USERCFG" ]; then
	    echo "Error[$DAEMON]: not configured" >&2
	    exit 1
	fi
	;;
esac

start_daemon() {
    echo -n "Starting $DAEMON..."
    if [ "$CALLMONITOR_DEBUG" = "yes" ]; then
	"$DAEMON" --debug > /dev/null 2>&1
    else 
	"$DAEMON" > /dev/null 2>&1
    fi
    check_status
}
stop_daemon() {
    echo -n "Stopping $DAEMON..."
    "$DAEMON" -s
    check_status
}

try_start() {
    if [ "$CALLMONITOR_ENABLED" != "yes" ]; then
	echo "$DAEMON is disabled" >&2
	exit 1;
    fi

    start
}
start() {
    local exitval=0
    if is_running; then
	echo "$DAEMON already started."
	exit 0
    fi
    start_daemon || exitval=$?
    if [ $exitval -eq 0 -a "$CALLMONITOR_INTERFACE" = "fifo" ]; then
	telfifo enable "$FIFO"
    fi
    return $exitval
}
stop() {
    local exitval=0
    if telfifo list | grep -q -F "$FIFO"; then
	telfifo disable "$FIFO"
    fi
    stop_daemon || exitval=$?
    return $exitval
}
fast_restart() {
    ## keep pipe alive while callmonitor is restarted
    cat "$FIFO" > /dev/null &
    catpid=$!
    stop_daemon && start_daemon && kill "$catpid" > /dev/null 2>&1
}
restart() {
    stop
    start
}

is_running() {
    [ -e "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2> /dev/null
}

case "$1" in
    ""|load)
	mod_register
	phonebook init 2> /dev/null
	try_start
	;;
    unload)
	stop
	mod_unregister
	;;
    try-start)
	try_start
	;;
    start)
	start
	;;
    stop)
	stop
	;;
    restart)
	if is_running; then
	    fast_restart
	else
	    restart
	fi
	;;
    status)
	if is_running; then
	    echo "running"
	else
	    echo "stopped"
	fi
	;;
    reload)
	if ! is_running; then
	    echo "$DAEMON is not running" >&2
	    exit 1
	fi
	kill -USR1 "$pid" > /dev/null 2>&1
	;;
    *)
	echo "Usage: $0 [load|unload|start|stop|restart|status|reload|try-start]" >&2
	exit 1
	;;
esac
