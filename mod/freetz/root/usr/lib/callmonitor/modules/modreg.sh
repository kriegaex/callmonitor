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

mod_register() {
    local flash=/tmp/flash/$DAEMON
    mkdir -p "$flash"
    if have webif; then
## requires [webif] /usr/lib/cgi-bin/callmonitor.cgi
## requires [webif] /usr/lib/cgi-bin/callmonitor/maint.cgi
	modreg cgi $DAEMON 'Callmonitor'
	modreg daemon $DAEMON
	modreg extra $DAEMON '$(lang de:"Wartung" en:"Maintenance")' 1 'maint'
## requires [webif & monitor] /usr/lib/cgi-bin/callmonitor/testcall.cgi
## requires [webif & monitor] /usr/lib/cgi-bin/callmonitor/dump.cgi
## requires [webif & monitor] /usr/lib/cgi-bin/callmonitor/exec.cgi
## requires [webif & monitor] /etc/default.callmonitor/listeners.def
	if have monitor; then
	    modreg extra $DAEMON '$(lang de:"Testanruf" en:"Test call")' 1 'testcall'
	    modreg extra $DAEMON '' 2 'exec'
	    # modreg extra $DAEMON '$(lang de:"Anruf-Ereignisse" en:"Call events")' 1 'dump'
	    modreg file $DAEMON 'listeners' '$(lang de:"Regeln" en:"Rules")' 0 "listeners"
	fi
	if have phonebook; then
## requires [webif & phonebook] /usr/lib/cgi-bin/callmonitor/reverse.cgi
## requires [webif & phonebook] /usr/lib/cgi-bin/callmonitor/testlookup.cgi
## requires [webif & phonebook] /etc/default.callmonitor/callers.def
	    modreg extra $DAEMON '$(lang de:"Rückwärtssuche" en:"Reverse lookup")' 1 'reverse'
	    modreg extra $DAEMON '$(lang de:"Test der Rückwärtssuche" en:"Test reverse lookup")' 1 'testlookup'
	    modreg file $DAEMON 'callers' '$(lang de:"Telefonbuch" en:"Phone book")' 1 "callers"
	fi
    fi
}
mod_unregister() {
    if have webif; then
	if have phonebook; then
	    modunreg file $DAEMON 'callers'
	    modunreg extra $DAEMON 'testlookup'
	    modunreg extra $DAEMON 'reverse'
	fi
	if have monitor; then
	    modunreg file $DAEMON 'listeners'
	    # modunreg extra $DAEMON 'dump'
	    modunreg extra $DAEMON 'exec'
	    modunreg extra $DAEMON 'testcall'
	fi
	modunreg extra $DAEMON 'maint'
	modunreg daemon $DAEMON
	modunreg cgi $DAEMON
    fi
}
