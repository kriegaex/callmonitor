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
    ) [<a href='$(href extra callmonitor exec)?jfritz=on'>$(lang de:"Einschalten" en:"Enable")</a>]
    </li>
"
}

_j_cgi_is_up() {
    echo "
    <li>$(lang
	de:"Die CallMonitor-Schnittstelle ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) ist aktiviert."
	en:"The CallMonitor interface ($CALLMONITOR_MON_HOST:$CALLMONITOR_MON_PORT) is active."
    ) [<a href='$(href extra callmonitor exec)?jfritz=off'>$(lang de:"Ausschalten" en:"Disable")</a>]
"
}
