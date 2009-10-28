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

## requires /usr/lib/cgi-bin/callmonitor/exec.cgi

_j_cgi_is_down() {
    echo "
    <li><strong style='color: red'>$(lang 
	de:"Die CallMonitor-Schnittstelle ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) ist nicht aktiv."
	en:"The CallMonitor interface ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) is not active."
    )</strong>
    $(lang
	de:"Sie wird zum Betrieb des Callmonitors benötigt und normalerweise
	    automatisch aktiviert."
	en:"It is required for Callmonitor's operation and is normally enabled
	    automatically."
    ) [<a href='/cgi-bin/extras.cgi/callmonitor/exec?jfritz=on'>$(lang de:"Einschalten" en:"Enable")</a>]
    </li>
"
}

_j_cgi_is_up() {
    echo "
    <li>$(lang
	de:"Die CallMonitor-Schnittstelle ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) ist aktiviert."
	en:"The CallMonitor interface ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) is active."
    ) [<a href='/cgi-bin/extras.cgi/callmonitor/exec?jfritz=off'>$(lang de:"Ausschalten" en:"Disable")</a>]
"
}
