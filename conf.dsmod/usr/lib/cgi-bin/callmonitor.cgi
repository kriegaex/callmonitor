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

remote_tel_chk='' local_tel_chk=''
case "$CALLMONITOR_TELEFON_IP" in
	"") local_tel_chk=' checked' ;;
	"*") remote_tel_chk=' checked' ;;
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
<h2>Zugriff von außen erlauben? (Port 1011)</h2>
<p>
<input type="radio" name="telefon_ip" value="*"$remote_tel_chk id="t1">
<label for="t1">Ja</label>
<input type="radio" name="telefon_ip" value=""$local_tel_chk id="t2">
<label for="t2">Nein</label>
</p>
EOF

sec_end
