##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2007  Andreas Bühmann <buehmann@users.berlios.de>
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
    local type=query key value extra=
    case $1 in
	forward)
	    key="forwardrules:settings/rule$((${2:-1}-1))/activated"
	    if ? "${3:+1}"; then
		type=post value="$(_c_boolean "${3:-on}")"
	    fi
	    ;;
	wlan)
	    key="wlan:settings/ap_enabled"
	    if ? "${3:+1}"; then
		type=post value="$(_c_boolean "${2:-on}")"
	    fi
	    ;;
	sip)
	    key="sip:settings/sip$((${2:-1}-1))/activated"
	    if ? "${3:+1}"; then
		type=post value="$(_c_boolean "${3:-on}")"
	    fi
	    ;;
	diversion)
	    key="telcfg:settings/Diversity$((${2:-1}-1))/Active"
	    extra="telcfg:settings/RefreshDiversity"
	    if ? "${3:+1}"; then
		type=post value="$(_c_boolean "${3:-on}")"
	    fi
	    ;;
	*)
	    type=fail
	    ;;
    esac
    case $type in
	post) webui_login; webui_post_form "$key=$value" > /dev/null ;;
	query) webui_login; echo $(_c_f_boolean $(webui_query "$extra" "$key" | tail +2)) ;;
	fail) echo "Unknown configuration '$1'" >&2; return 1 ;;
    esac
}

_c_boolean() {
    case $1 in
	on|yes|true|1) echo "1" ;;
	off|no|false|0) echo "0" ;;
    esac
}
_c_f_boolean() {
    case $1 in
	1) echo "on" ;;
	0) echo "off" ;;
	*) echo "error" ;;
    esac
}

