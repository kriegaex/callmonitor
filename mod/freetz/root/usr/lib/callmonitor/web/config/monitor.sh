require if_jfritz_status
require if_jfritz_cgi

check "$CALLMONITOR_ENABLED" yes:auto *:man
check "$CALLMONITOR_DEBUG" yes:debug

SYSLOG='$(lang de:"System-Log" en:"system log")'
if has_package syslogd; then
    SYSLOG="<a href='pkgconf.cgi?pkg=syslogd'>$SYSLOG</a>"
fi

sec_begin '$(lang de:"Starttyp" en:"Startup type")'

echo "
<p>
    <input type='radio' name='enabled' value='yes'$auto_chk id='e1'>
    <label for='e1'>$(lang de:"Automatisch" en:"Automatic")</label>
    <input type='radio' name='enabled' value='no'$man_chk id='e2'>
    <label for='e2'>$(lang de:"Manuell" en:"Manual")</label>
</p>
"
if [ "$CALLMONITOR_EXPERT" = yes ]; then
    echo "
    <p>
	<input type='hidden' name='debug' value='no'>
	<input type='checkbox' name='debug' value='yes'$debug_chk id='d1'>
	<label for='d1'>$(lang 
	    de:"mit Debug-Ausgaben" 
	    en:"with debugging output"
	)</label> ($(lang de:"ins" en:"into the") $SYSLOG)
    </p>
    "
fi
sec_end

if [ "$CALLMONITOR_EXPERT" = yes ]; then
    sec_begin '$(lang de:"Monitor" en:"Monitor")'

    echo "
    <p>
	<label for='m1'>$(lang de:"Zu überwachende Box" en:"Box to be monitored")</label>:
	<input type='text' name='mon_host' value='$(html "$CALLMONITOR_MON_HOST")' 
	    size='16' id='m1'>
	<label for='m2'>Port:</label>
	<input type='text' name='mon_port' value='$(html "$CALLMONITOR_MON_PORT")'
	    size='6' maxlength='5' id='m2'>
    </p>
    "
    sec_end
fi

if ! _j_is_up; then
    sec_begin '$(lang de:"Status" en:"Status")'
    echo '<ul>'
    _j_cgi_is_down
    echo '</ul>'
    sec_end
fi

sec_begin '$(lang de:"Aktionen bei Anruf" en:"Actions upon calls")'

echo "
<ul>
    <li><a href='/cgi-bin/file.cgi?id=listeners'>$(lang
	de:"Listeners bearbeiten" en:"Edit Listeners")</a></li>
    <li><a href='/cgi-bin/extras.cgi/callmonitor/testcall'>$(lang
	de:"Testanruf durchführen" en:"Perform test call")</a></li>
</ul>
"

sec_end
