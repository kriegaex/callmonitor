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

## analyze call information
__read() {
    trap '' CHLD
    local timestamp event id ext source dest remote duration
    while __j_parse; do

	## complete information
	case $event in
	    CONNECT)	__j_load source dest ;;
	    DISCONNECT)	__j_load source dest ext ;;
	esac

	local state output
	__j_load state
	output=$(__j_transition)
	__j_output $output
	
	if [ "$state" = "disconnected" ]; then
	    __j_remove state source dest ext
	else
	    case $event in
		CALL|RING)  __j_store source dest ;;
		CONNECT)    __j_store source dest ext ;;
	    esac
	    __j_store state
	fi
    done
}

## separate state maschine for each connection id
__j_transition() {
    local output=
    case $state in
	""|disconnected)
	    case $event in
		CALL)	    state=calling	output=out:request ;;
		RING)	    state=ringing	output=in:request ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	calling)
	    case $event in
		CONNECT)    state=connected:out	output=out:begin
			    dest=$remote
		;;
		DISCONNECT) state=disconnected	output=out:cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	ringing)
	    case $event in
		CALL)	    state=accepted:in	output=in:accept ;;
		CONNECT)    state=connected:in	output=in:begin
			    source=$remote
		;;
		DISCONNECT) state=disconnected	output=in:cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	accepted:in)
	    case $event in
		CONNECT)    state=connected:in	output=in:begin
			    source=$remote
		;;
		DISCONNECT) state=disconnected	output=in:cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	connected:in)
	    case $event in
		DISCONNECT) state=disconnected	output=in:end ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	connected:out)
	    case $event in
		DISCONNECT) state=disconnected	output=out:end ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
    esac
    echo "$output"
}

__j_parse() {
    local _1 _2 _3 _4 empty
    IFS=';' read -r timestamp event _1 _2 _3 _4 empty
    id=$_1
    __debug "timestamp: $timestamp"
    __debug "event: $event"
    __debug "id: $id"
    unset ext source dest remote duration
    case $event in
	CALL)
	    ext=$_2
	    source=$_3
	    dest=$_4
	    __debug "ext: $ext"
	    __debug "source: $source"
	    __debug "dest: $dest"
	;;
	RING)
	    source=$_2
	    dest=$_3
	    __debug "source: $source"
	    __debug "dest: $dest"
	;;
	CONNECT)
	    ext=$_2
	    remote=$_3
	    __debug "ext: $ext"
	    __debug "remote: $remote"
	;;
	DISCONNECT)
	    duration=$_2
	    __debug "duration: $duration"
	;;
    esac
}

__read_from_iface() {
    nc 127.0.0.1 1012 | __read
}

__init_iface() {
    :
}

## process an "IncomingCall" line
#__incoming_call_line() {
#    local line="$1"
#    local SOURCE="${line##*caller: \"}"; SOURCE="${SOURCE%%\"*}"
#    local DEST="${line##*called: \"}"; DEST="${DEST%%\"*}"
#    local SOURCE_NAME="" DEST_NAME="" NT=false END=false
#    local SOURCE_OPTIONS= DEST_OPTIONS=
#    __debug "detected '$line'"
#    case "$line" in
#	*"IncomingCall from NT:"*) NT=true ;; 
#    esac
#
#    ## only one reverse lookup; it is expensive
#    if $NT; then
#	SOURCE_OPTIONS="--local"
#    else
#	DEST_OPTIONS="--local"
#    fi
#    incoming_call
#}

## process an "outgoing" summary line at end of call
#__end_outgoing_line() {
#    local line="$1"
#    local SOURCE="${line% outgoing*}"; SOURCE="${SOURCE##* }"
#    local DEST="${line% ChargeU*}"; DEST="${DEST##* }" 
#
#    ## NT cannot be detected; let's simply assume local outbound call
#    local SOURCE_NAME="" DEST_NAME="" NT=true END=true
#    local SOURCE_OPTIONS="--local" DEST_OPTIONS="--local"
#    __debug "detected '$line'"
#    incoming_call
#}
__j_output() {
    __debug '>>>' "$@"
    __debug '   ' ID=$id
    __debug '   ' TIMESTAMP=$timestamp
    __debug '   ' SOURCE=$source
    __debug '   ' DEST=$dest
    __debug '   ' EXT=$ext
    __debug '   ' DURATION=$duration
    __debug '<<<'
}

#	    *"IncomingCall"*"caller: "*"called: "*)
#		__incoming_call_line "$line" &
#		let INSTANCE++

## store attributes per connection id
__j_store() {
    eval $(for var; do echo "${var}_${id}=\"\$${var}\""; done)
}
__j_load() {
    eval $(for var; do echo "${var}=\"\$${var}_${id}\""; done)
}
__j_remove() {
    eval unset $(for var; do echo "${var}" "${var}_${id}"; done)
}
