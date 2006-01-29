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

## copy stdin to stdout while looking for incoming calls
__read() {
    trap '' CHLD
    local line
    while IFS= read -r line
    do
	echo "$line"
	case $line in
	    *"IncomingCall"*"caller: "*"called: "*)
		__incoming_call_line "$line" &
		let INSTANCE++
	    ;;
	    *Slot:*ID:*CIP:*outgoing*)
		__end_outgoing_line "$line" &
		let INSTANCE++
	    ;;
	esac
    done
}

__read_from_iface() {
    __read < "$CALLMONITOR_FIFO"
}

__init_iface() {
    mkdir -p "$(dirname "$CALLMONITOR_FIFO")"

    if [ ! -p "$CALLMONITOR_FIFO" ]; then
	mknod "$CALLMONITOR_FIFO" p
    fi
}

## process an "IncomingCall" line
__incoming_call_line() {
    local line="$1"
    local SOURCE="${line##*caller: \"}"; SOURCE="${SOURCE%%\"*}"
    local DEST="${line##*called: \"}"; DEST="${DEST%%\"*}"
    local SOURCE_NAME="" DEST_NAME="" NT=false END=false EVENT=out:request
    local SOURCE_OPTIONS= DEST_OPTIONS=
    __debug "detected '$line'"
    case "$line" in
	*"IncomingCall from NT:"*) NT=true ;; 
    esac

    ## only one reverse lookup; it is expensive
    if $NT; then
	SOURCE_OPTIONS="--local"
    else
	DEST_OPTIONS="--local"
    fi
    incoming_call
}

## process an "outgoing" summary line at end of call
__end_outgoing_line() {
    local line="$1"
    local SOURCE="${line% outgoing*}"; SOURCE="${SOURCE##* }"
    local DEST="${line% ChargeU*}"; DEST="${DEST##* }" 

    ## NT cannot be detected; let's simply assume local outbound call
    local SOURCE_NAME="" DEST_NAME="" NT=true END=true EVENT=end
    local SOURCE_OPTIONS="--local" DEST_OPTIONS="--local"
    __debug "detected '$line'"
    incoming_call
}
