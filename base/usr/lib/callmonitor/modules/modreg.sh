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
## requires [webif & phonebook] /etc/default.callmonitor/callers.def
	    modreg extra $DAEMON '$(lang de:"Rückwärtssuche" en:"Reverse lookup")' 1 'reverse'
	    modreg file $DAEMON 'callers' '$(lang de:"Telefonbuch" en:"Phone book")' 1 "callers"
	fi
    fi
}
mod_unregister() {
    if have webif; then
	if have phonebook; then
	    modunreg file $DAEMON 'callers'
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
