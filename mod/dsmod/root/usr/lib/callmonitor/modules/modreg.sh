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
mod_register() {
    local DAEMON=callmonitor deffile=
    modreg cgi $DAEMON 'Callmonitor'
    modreg extra $DAEMON 'Testanruf' 1 'testcall'
    modreg extra $DAEMON 'Wartung' 1 'maint'
    if [ -r "/tmp/flash/$DAEMON/listeners.def" ]; then 
	deffile="/tmp/flash/$DAEMON/listeners.def"
    else 
	deffile="/etc/default.$DAEMON/listeners.def"
    fi
    modreg file 'listeners' 'Listeners' 0 "$deffile"
    if [ -r "/tmp/flash/$DAEMON/callers.def" ]; then 
	deffile="/tmp/flash/$DAEMON/callers.def"
    else 
	deffile="/etc/default.$DAEMON/callers.def"
    fi
    modreg file 'callers' 'Callers' 1 "$deffile"
}
mod_unregister() {
    modunreg file 'callers'
    modunreg file 'listeners'
    modunreg extra $DAEMON 'testcall'
    modunreg extra $DAEMON 'maint'
    modunreg cgi $DAEMON
}
