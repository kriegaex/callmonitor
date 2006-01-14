usage() {
	cat <<EOF
#<
Usage:	$APPLET [OPTION]... SOURCE [DEST]
Options:
	-n	generate call "from NT"
	-s	output to stdout instead of callmonitor's fifo
	--help	show this help
#>
EOF
}
TEMP="$(getopt -o 'ns' -l 'help' -n "$APPLET" -- "$@")" || exit 1
eval "set -- $TEMP"

NT=false
STDOUT=false
while true; do
	case $1 in
		-n) NT=true ;;
		-s) STDOUT=true ;;
		--help) usage >&2; exit 1 ;;
		--) shift; break ;;
		*) ;; # should never happen
	esac
	shift
done
if [ $# -lt 1 ]; then
	usage >&2; exit
fi
SOURCE="$1"
DEST="${2:-SIP0}"

## check if fifo exists and if callmonitor is running
if ! $STDOUT; then
	FIFO="$CALLMONITOR_FIFO"
	if [ ! -p "$FIFO" ]; then
		echo "callmonitor's fifo $FIFO does not exist" >&2
		exit 1
	fi
	status="$("$CALLMONITOR_ROOT/etc/init.d/rc.callmonitor" status)"
	if [ "$status" != "running" ]; then
		echo "callmonitor seems not to be running" >&2
		exit 1
	fi
fi

## IncomingCall from NT: ID 0, caller: "0927340284" called: "234972"
## IncomingCall: ID 0, caller: "02938423742" called: "SIP0"
if $NT; then
	PATTERN='\nIncomingCall from NT: ID 0, caller: "%s" called: "%s"\n'
else
	PATTERN='\nIncomingCall: ID 0, caller: "%s" called: "%s"\n'
fi
if $STDOUT; then
	printf "$PATTERN" "$SOURCE" "$DEST"
else
	printf "$PATTERN" "$SOURCE" "$DEST" > "$FIFO"
fi
