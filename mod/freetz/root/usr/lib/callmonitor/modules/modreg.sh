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

## requires /etc/default.callmonitor/listeners.def
## requires /etc/default.callmonitor/callers.def
mod_register() {
    local deffile flash=/tmp/flash/$DAEMON def="/mod/etc/default.$DAEMON"
    mkdir -p "$flash"
    if have webif; then
	modreg cgi $DAEMON 'Callmonitor'
	modreg extra $DAEMON '$(lang de:"Testanruf" en:"Test call")' 1 'testcall'
	modreg extra $DAEMON '$(lang de:"Wartung" en:"Maintenance")' 1 'maint'
	modreg file 'listeners' 'Listeners' 0 "$def/listeners.def"
	if have phonebook; then
	    modreg extra $DAEMON '$(lang de:"Rückwärtssuche-Anbieter" en:"Reverse-lookup providers")' 1 'reverse'
	    modreg extra $DAEMON '$(lang de:"Test der Rückwärtssuche" en:"Test reverse lookup")' 1 'testlookup'
	    modreg file 'callers' 'Callers' 1 "$def/callers.def"
	fi
    fi
}
mod_unregister() {
    if have webif; then
	if have phonebook; then
	    modunreg file 'callers'
	    modunreg extra $DAEMON 'testlookup'
	    modunreg extra $DAEMON 'reverse'
	fi
	modunreg file 'listeners'
	modunreg extra $DAEMON 'testcall'
	modunreg extra $DAEMON 'maint'
	modunreg cgi $DAEMON
    fi
}
