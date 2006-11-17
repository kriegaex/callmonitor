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

require webui

config() {
    local type data
    case $1 in
	forward) type=post data="forwardrules:settings/rule$((${2:-1}-1))/activated=$(_c_boolean "${3:-on}")" ;;
	wlan)    type=post data="wlan:settings/ap_enabled=$(_c_boolean "${2:-on}")" ;;
	sip)     type=post data="sip:settings/sip$((${2:-1}-1))/activated=$(_c_boolean "${3:-on}")" ;;
	*)       type=fail ;;
    esac
    case $type in
	post) webui_login; webui_post_form "$data" > /dev/null ;;
	fail) echo "Unknown configuration '$1'" >&2; return 1 ;;
    esac
}

_c_boolean() {
    case $1 in
	on|yes|true|1) echo "1" ;;
	off|no|false|0) echo "0" ;;
    esac
}
