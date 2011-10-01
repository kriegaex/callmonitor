## run callmonitor in test mode: do not run as a daemon, do not write
## pid file, show trace of rule processing for simplified call on stdout

require callmonitor

__debug() { echo "$*"; }
__info() { echo "$*"; }

__configure

event=$1 source=$2 dest=$3

## dummy values
id=1 ext=4 duration=16 timestamp=$(date +"%d.%m.%y %H:%M")

_j_output "$event"

wait
exit 0
