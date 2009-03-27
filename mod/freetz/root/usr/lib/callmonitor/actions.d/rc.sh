##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2008  Andreas Bühmann <buehmann@users.berlios.de>
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

rc() {
    local service=$1; shift
    local dir rc
    for dir in /mod/etc/init.d /etc/init.d ""; do
	[ "$dir" == "" ] && return 1
	rc="$dir/rc.$service"
	[ -x "$rc" ] && break
    done
    if [ "$#" -eq 0 ]; then
	echo "$rc"
	return
    fi
    local cmd=$1; shift
    case $cmd in
    	toggle)
	    case $("$rc" status) in
	    	running) "$rc" stop ;;
		stopped) "$rc" start ;;
	    esac
	    ;;
	*)
	    "$rc" "$cmd" "$@"
	    ;;
    esac
}

## start or stop ssh daemon
droptoggle() {
    rc dropbear toggle
}

## start ssh daemon
dropon() {
    rc dropbear start
}

## stop ssh daemon
dropoff() {
    rc dropbear stop
}
