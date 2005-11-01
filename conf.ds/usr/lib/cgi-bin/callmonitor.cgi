#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
if [ "$CALLMONITOR_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

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
sec_begin 'R�ckw�rtssuche'

cat << EOF
<h2>R�ckw�rtssuche durchf�hren und Ergebnis speichern?</h2>
<p>
<input type="radio" name="reverse" value="no"$no_chk id="r1">
<label for="r1">Nein</label>
<input type="radio" name="reverse" value="transient"$trans_chk id="r2">
<label for="r2">Fl�chtig</label>
<input type="radio" name="reverse" value="persistent"$pers_chk id="r3">
<label for="r3">Dauerhaft</label>
</p>
<h2>Bei R�ckw�rtssuche f�r lokale Rufnummern diese Vorwahl verwenden:</h2>
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
<p>Bei <kbd>*</kbd> ist telefon von �berall erreichbar. Ist
keine Adresse angegeben, werden die Standardeinstellungen verwendet.<p>
EOF

sec_end