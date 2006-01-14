usage() {
	cat <<EOF
#<
Usage:	$APPLET [OPTION]...
Options:
	-f	run in foreground
	-s	stop the callmonitor
	--debug	log rule matching/executed commands to syslog
		(and to stderr with -f)
	--help	show this help
#>
EOF
}

require callmonitor

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
		if $DEBUG; then
			__debug() { logger -s -t "$APPLET" -p daemon.debug "$*"; }
		fi
		__info() { logger -s -t "$APPLET" -p daemon.info "$*"; }
		incoming_call() { __incoming_call "$@"; }
	else
		if $DEBUG; then
			__debug() { logger -t "$APPLET" -p daemon.debug "$*"; }
		fi
		__info() { logger -t "$APPLET" -p daemon.info "$*"; }
		incoming_call() { __incoming_call "$@" > /dev/null 2>&1; }
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
		__read < "$FIFO"
	done
}

PIDFILE="/var/run/callmonitor.pid"
FIFO="$CALLMONITOR_FIFO"

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
	mkdir -p "$(dirname "$FIFO")"

	if [ ! -p "$FIFO" ]; then
		mknod "$FIFO" p
	fi

	if $FOREGROUND; then
		echo $$ > "$PIDFILE"
		__work
	else
		__work &
		echo $! > "$PIDFILE"
	fi
fi
