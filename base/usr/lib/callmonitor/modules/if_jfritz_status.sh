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

require dial

_j_is_up() {
    busybox nc "$CALLMONITOR_MON_HOST" "$CALLMONITOR_MON_PORT" < /dev/null > /dev/null 2>&1
}

_j_dial() {
    case $CALLMONITOR_MON_HOST in
	localhost|127.0.0.1|) dial "$1" ;;
	*) echo "Cannot $2 interface of remote box; please dial $1 manually" ;;
    esac
}
_j_enable() {
    _j_dial "#96*5*" enable
}

_j_disable() {
    _j_dial "#96*4*" disable
}
