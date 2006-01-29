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
    local timestamp event id ext source dest remote duration
    while __j_parse; do

	## complete information
	case $event in
	    CONNECT)	__j_load source dest ;;
	    DISCONNECT)	__j_load source dest ext ;;
	esac

	local state output
	__j_load state
	__j_transition
	
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
    case $state in
	""|disconnected)
	    case $event in
		CALL)	    state=calling	output=out-request ;;
		RING)	    state=ringing	output=in-request ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	calling)
	    case $event in
		CONNECT)    state=connected:out	output=out-start
			    dest=$remote
		;;
		DISCONNECT) state=disconnected	output=out-cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	ringing)
	    case $event in
		CALL)	    state=accepted:in	output=in-accept ;;
		CONNECT)    state=connected:in	output=in-begin
			    source=$remote
		;;
		DISCONNECT) state=disconnected	output=in-cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	accepted:in)
	    case $event in
		CONNECT)    state=connected:in	output=in-start
			    source=$remote
		;;
		DISCONNECT) state=disconnected	output=in-cancel ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	connected:in)
	    case $event in
		DISCONNECT) state=disconnected	output=in-end ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
	connected:out)
	    case $event in
		DISCONNECT) state=disconnected	output=out-end ;;
		*)	    state=disconnected  output=error ;;
	    esac
	;;
    esac
    let INSTANCE++
    __j_output "$output" &
}

__j_parse() {
    local _1 _2 _3 _4 empty
    IFS=';' read -r timestamp event _1 _2 _3 _4 empty || return 1
    id=$_1
    __debug '<<<'
    __debug '   ' "timestamp: $timestamp"
    __debug '   ' "event: $event"
    __debug '   ' "id: $id"
    unset ext source dest remote duration
    case $event in
	CALL)
	    ext=$_2
	    source=$_3
	    dest=$_4
	    __debug '   ' "ext: $ext"
	    __debug '   ' "source: $source"
	    __debug '   ' "dest: $dest"
	;;
	RING)
	    source=$_2
	    dest=$_3
	    __debug '   ' "source: $source"
	    __debug '   ' "dest: $dest"
	;;
	CONNECT)
	    ext=$_2
	    remote=$_3
	    __debug '   ' "ext: $ext"
	    __debug '   ' "remote: $remote"
	;;
	DISCONNECT)
	    duration=$_2
	    __debug '   ' "duration: $duration"
	;;
	*)
	    return 1
	;;
    esac
    __debug '<<<'
    return 0
}

__read_from_iface() {
    let "__J_SLEEP = (__J_SLEEP < 1) ? 1 : __J_SLEEP"
    if ! nc 127.0.0.1 1012 < /dev/null > /dev/null 2>&1; then
	__info "Please use #96*5* to enable telefon's interface."
        __info "Trying again in $__J_SLEEP seconds ..."

	sleep "$__J_SLEEP"
	let "__J_SLEEP *= 2"
	let "__J_SLEEP = (__J_SLEEP > 600) ? 600 : __J_SLEEP"
    else
	__J_SLEEP=
	nc 127.0.0.1 1012 | __read
    fi
}

__init_iface() {
    :
}

__j_output() {
    local output="$1"
    __debug '>>>' "$@"
    __debug '   ' ID=$id
    __debug '   ' TIMESTAMP=$timestamp
    __debug '   ' SOURCE=$source
    __debug '   ' DEST=$dest
    __debug '   ' EXT=$ext
    __debug '   ' DURATION=$duration
    __debug '>>>'

    local ID=$id SOURCE=$source DEST=$dest EXT=$ext DURATION=$duration
    local TIMESTAMP=$timestamp EVENT= SOURCE_OPTIONS= DEST_OPTIONS=
    export EVENT ID SOURCE DEST EXT DURATION TIMESTAMP
    case $output in
	in-request|in-cancel|in-start|in-end)
	    EVENT=$output
	    DEST_OPTIONS="--local"
	;;
	out-request|out-cancel|out-start|out-end)
	    EVENT=$output
	    SOURCE_OPTIONS="--local"
	;;
    esac
    if [ -n "$output" ]; then
	incoming_call
    fi
}

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
