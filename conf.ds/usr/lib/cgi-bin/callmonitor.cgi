#!/bin/sh
. /usr/lib/libmodcgi.sh

auto_chk='' man_chk=''
if [ "$CALLMONITOR_ENABLED" = "yes" ]; then
	auto_chk=' checked'
else
	man_chk=' checked'
fi

normal_chk='' debug_chk=''
if [ "$CALLMONITOR_DEBUG" = "yes" ]; then
	normal_chk=' checked'
else 
	debug_chk=' checked'
fi

no_chk='' trans_chk='' pers_chk=''
case "$CALLMONITOR_REVERSE" in
	no) no_chk=' checked' ;;
	transient) trans_chk=' checked' ;;
	persistent) pers_chk=' checked' ;;
esac

sec_begin 'Starttyp'

cat << EOF
<p>
<input type="radio" name="enabled" value="yes"$auto_chk id="e1">
<label for="e1">Automatisch</label>
<input type="radio" name="enabled" value="no"$man_chk id="e2">
<label for="e2">Manuell</label>
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
<h2>Rückwärtssuche durchführen und Ergebnis speichern?</h2>
<p>
<input type="radio" name="reverse" value="no"$no_chk id="r1">
<label for="r1">Nein</label>
<input type="radio" name="reverse" value="transient"$trans_chk id="r2">
<label for="r2">Flüchtig</label>
<input type="radio" name="reverse" value="persistent"$pers_chk id="r3">
<label for="r3">Dauerhaft</label>
(<a href="/cgi-bin/file.cgi?id=callers">Callers bearbeiten</a>)
</p>
<h2>Bei Rückwärtssuche für lokale Rufnummern diese Vorwahl verwenden:</h2>
<p>
<label for="okz">Vorwahl:</label>
<input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")" id="okz">
</p>
EOF

sec_end
sec_begin 'Telefon-Daemon'

cat << EOF
<h2>Adresse, unter der telefon auf Port 1011 lauscht:</h2>
<p>
<label for="ip">IP/Hostname:</label>
<input type="text" name="telefon_ip" value="$(httpd -e "$CALLMONITOR_TELEFON_IP")" id="ip">
</p>
<p>Bei <kbd>*</kbd> ist telefon von überall erreichbar, bei keiner
Adresse nur von der Fritz!Box selbst.<p>
EOF

sec_end
