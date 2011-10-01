## modflash-later: flash at most $1 seconds later

require lock
## requires /usr/lib/callmonitor/modflash-now

FLASH=/tmp/flash
LATER_NAME=modflash-later
NOW_NAME=modflash-now
DEFAULT_MAX=600

DIR=$(dirname "$0")
NAME=$(basename "$0")

case $NAME in
    "$LATER_NAME")
	MAX=${1:-$DEFAULT_MAX}
	sleep "$MAX" &
	trap "kill $! 2> /dev/null; exit" TERM
	wait
	if lock "$FLASH"; then
	    ## in case something goes wrong
	    trap 'unlock "$FLASH"' EXIT

	    ## change name so we do not kill ourselves
	    exec "$DIR/$NOW_NAME"
	fi
	;;
    "$NOW_NAME")
	## kill all of our competitors
	killall -q "$LATER_NAME"
	modsave flash
	unlock "$FLASH"
	;;
esac
