## run callmonitor in test mode: do not run as a daemon, do not write
## pid file, read from stdin only once, show trace of rule processing
## on stdout

require callmonitor

__debug() { echo "$*"; }
__info() { echo "$*"; }

__configure
__read
wait
exit 0
