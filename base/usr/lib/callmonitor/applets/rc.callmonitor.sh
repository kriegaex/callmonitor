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

## we no longer need the telefon package

require rc
require modreg

FIFO="$CALLMONITOR_FIFO"
FIFO_DIR="${FIFO%/*}"
mkdir -p "$FIFO_DIR"
PIDFILE="/var/run/$DAEMON/pid/$DAEMON"

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
    case $CALLMONITOR_DEBUG in
	yes) "$DAEMON" --debug > /dev/null 2>&1 ;; 
	*) "$DAEMON" > /dev/null 2>&1 ;;
    esac
    check_status
}
stop_daemon() {
    echo -n "Stopping $DAEMON..."
    "$DAEMON" -s
    check_status
}

try_start() {
    case $CALLMONITOR_ENABLED in yes) ;; *)
	echo "$DAEMON is disabled" >&2
	exit 1
    ;; esac

    start
}
start() {
    local exitval=0
    if is_running; then
	echo "$DAEMON already started."
	exit 0
    fi
    start_daemon || exitval=$?
    return $exitval
}
stop() {
    local exitval=0
    stop_daemon || exitval=$?
    return $exitval
}
restart() {
    stop
    start
}

is_running() {
    local pid
    [ -e "$PIDFILE" ] && read pid < "$PIDFILE" && 
	kill -0 "$pid" 2> /dev/null
}

## convert listeners from versions < 1.0
convert() {
    if [ ! -e "$CALLMONITOR_LISTENERS" -a -r "$CALLMONITOR_LISTENERS_OLD" ]
    then
	"$CALLMONITOR_LIBDIR/convert.sed" \
	    < "$CALLMONITOR_LISTENERS_OLD" \
	    > "$CALLMONITOR_LISTENERS"
	callmonitor_store
    fi
    # after two month, delete obsolete listeners
    if [ -e "$CALLMONITOR_LISTENERS" -a -e "$CALLMONITOR_LISTENERS_OLD" ]
    then
	find "$(dirname "$CALLMONITOR_LISTENERS_OLD")" -type f \
	    -name "$(basename "$CALLMONITOR_LISTENERS_OLD")" -mtime +60 \
	    -exec rm {} \;
	callmonitor_store
    fi
}

case "$1" in
    ""|load)
	convert
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
	restart
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
	read pid < "$PIDFILE" &&
	    kill -USR1 "$pid" > /dev/null 2>&1
	;;
    *)
	echo "Usage: $0 [load|unload|start|stop|restart|status|reload|try-start]" >&2
	exit 1
	;;
esac
