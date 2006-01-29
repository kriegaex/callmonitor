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
usage() {
#<
    cat <<EOF
Usage:	$APPLET [OPTION]...
Options:
    -f		run in foreground
    -s		stop the callmonitor
    --debug     log rule matching/executed commands to syslog
		(and to stderr with -f)
    --help	show this help
EOF
#>
}

require callmonitor
require "if_$CALLMONITOR_INTERFACE"

## parse options
TEMP="$(getopt -o 'fs' -l debug,help -n "$APPLET" -- "$@")" || exit 1
eval "set -- $TEMP"

DEBUG=false
FOREGROUND=false
STOP=false
while true; do
    case $1 in
	-f) FOREGROUND=true ;;
	-s) STOP=true ;;
	--debug) DEBUG=true ;;
	--help) usage >&2; exit ;;
	--) shift; break ;;
	*) ;; # should never happen
    esac
    shift
done

## pass options to phonebook
PHONEBOOK_OPTIONS=""
if $DEBUG; then
    PHONEBOOK_OPTIONS="$PHONEBOOK_OPTIONS --debug"
fi

## set up logging
__log_setup() {
    if $FOREGROUND; then
	__logger() { logger -t "$APPLET" -s "$@"; }
	incoming_call() { __incoming_call "$@"; }
    else
	__logger() { logger -t "$APPLET" "$@"; }
	incoming_call() { __incoming_call "$@" > /dev/null 2>&1; }
    fi
    __info() { __logger -p daemon.info "$*"; }
    if $DEBUG; then
	__debug() { __logger -p daemon.debug "$*"; }
    fi
    __debug "entering DEBUG mode"
}

__work() {
    ## a USR1 signal will cause the callmonitor to re-read its configuration
    trap __configure USR1
    trap 'rm -f "$PIDFILE"' EXIT
    trap 'exit 2' HUP INT QUIT TERM

    ## initial configuration
    __log_setup
    __configure

    ## enter main loop
    while true; do
	__debug "beginning to read from interface $CALLMONITOR_INTERFACE"
	__read_from_iface
    done
}

PIDFILE="$CALLMONITOR_VAR/pid"

if $STOP; then
    if [ ! -e "$PIDFILE" ]; then
	echo "$APPLET: not running" 2>&1 
	exit 1
    else
	PID="$(cat "$PIDFILE")"
	kill "$PID" && rm -f "$PIDFILE"
	exit $?
    fi
else
    __init_iface

    if $FOREGROUND; then
	echo $$ > "$PIDFILE"
	__work
    else
	__work &
	echo $! > "$PIDFILE"
    fi
fi
