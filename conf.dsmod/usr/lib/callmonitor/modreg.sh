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
