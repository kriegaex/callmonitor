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
Usage: $APPLET [OPTION]... SOURCE [DEST]
Options:
    -n	    generate call "from NT"
    -e      generate end-of-call line
    -s	    output to stdout instead of callmonitor's fifo
    --help  show this help
EOF
#>
}
TEMP="$(getopt -o 'nes' -l 'help' -n "$APPLET" -- "$@")" || exit 1
eval "set -- $TEMP"

NT=false
END=false
STDOUT=false
while true; do
    case $1 in
	-n) NT=true ;;
	-e) END=true ;;
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
if $END; then
    PATTERN='11.01.06 20:36     0s Slot: -1 ID: 0 CIP: 16 %19s incoming %13s ChargeU:    0\n'
    printf "$PATTERN" "$DEST" "$SOURCE"
else
    if $NT; then
	PATTERN='\nIncomingCall from NT: ID 0, caller: "%s" called: "%s"\n'
    else
	PATTERN='\nIncomingCall: ID 0, caller: "%s" called: "%s"\n'
    fi
    printf "$PATTERN" "$SOURCE" "$DEST"
fi |
if $STDOUT; then
    cat
else
    cat > "$FIFO"
fi
