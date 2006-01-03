#!/bin/sh
. "${CALLMONITOR_CFG:=/mod/etc/default.callmonitor/system.cfg}"
require cgi

CHECKED=' checked'

auto_chk='' man_chk=''
if [ "$CALLMONITOR_ENABLED" = "yes" ]; then
	auto_chk=$CHECKED
else
	man_chk=$CHECKED
fi

debug_chk=''
if [ "$CALLMONITOR_DEBUG" = "yes" ]; then
	debug_chk=$CHECKED
fi

reverse_chk=''
if [ "$CALLMONITOR_REVERSE" = "yes" ]; then
	reverse_chk=$CHECKED
fi

no_chk='' trans_chk='' pers_chk=''
case "$CALLMONITOR_REVERSE_CACHE" in
	no) no_chk=$CHECKED ;;
	transient) trans_chk=$CHECKED ;;
	persistent) pers_chk=$CHECKED ;;
esac

SYSLOG='System-Log'
if has_package syslogd; then
	SYSLOG="<a href='pkgconf.cgi?pkg=syslogd'>$SYSLOG</a>"
fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input type="radio" name="enabled" value="yes"$auto_chk id="e1">
<label for="e1">Automatisch</label>
<input type="radio" name="enabled" value="no"$man_chk id="e2">
<label for="e2">Manuell</label>
</p>
<p>
<input type="hidden" name="debug" value="no">
<input type="checkbox" name="debug" value="yes"$debug_chk id="d1">
<label for="d1">mit Debug-Ausgaben</label> (ins $SYSLOG)
</p>
EOF

sec_end
sec_begin 'Aktionen bei Anruf'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=listeners">Listeners bearbeiten</a></li>
<li><a href="/cgi-bin/extras.cgi/callmonitor/testcall">Testanruf</a></li>
</ul>
EOF

sec_end
sec_begin 'Rückwärtssuche'

cat << EOF
<p>
<input type="hidden" name="reverse" value="no">
<input type="checkbox" name="reverse" value="yes"$reverse_chk id="r4">
<label for="r4">Rückwärtssuche durchführen</label> (bei <a href="http://www.dasoertliche.de/">DasÖrtliche</a>)
</p>
<h2>Suchergebnis zwischenspeichern?</h2>
<p>
<input type="radio" name="reverse_cache" value="no"$no_chk id="r1">
<label for="r1">Nein</label>
<input type="radio" name="reverse_cache" value="transient"$trans_chk id="r2">
<label for="r2">Flüchtig</label>
<input type="radio" name="reverse_cache" value="persistent"$pers_chk id="r3">
<label for="r3">Dauerhaft</label>
(<a href="/cgi-bin/file.cgi?id=callers">Callers bearbeiten</a>)
</p>
<h2>Für lokale Rufnummern diese Vorwahl verwenden:</h2>
<p>
<label for="okz">Vorwahl:</label>
<input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")" size="5" id="okz">
</p>
EOF

sec_end
