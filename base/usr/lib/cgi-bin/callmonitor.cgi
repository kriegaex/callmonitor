#!/bin/sh
auto_chk=''; man_chk=''
if [ "$CALLMONITOR_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

no_chk='' trans_chk='' pers_chk=''
case "$CALLMONITOR_REVERSE" in
	no) no_chk=' checked' ;;
	transient) trans_chk=' checked' ;;
	persistent) pers_chk=' checked' ;;
esac

ip_val="$(httpd -e "$CALLMONITOR_TELEFON_IP")"
okz_val="$(httpd -e "$CALLMONITOR_OKZ")"

cat << EOF
<h1>Call-Monitor-Konfiguration</h1>
<form action="/cgi-bin/save.cgi?form=pkg_callmonitor" method="post">
<p><i>Startverhalten von callmonitor beim Bootvorgang</i><br>
<input type="radio" name="enabled" value="yes"$auto_chk> Automatisch
<input type="radio" name="enabled" value="no"$man_chk> Manuell
</p>
<p><i>Rückwärtssuche durchführen und Ergebnis speichern</i><br>
<input type="radio" name="reverse" value="no"$no_chk> Nein
<input type="radio" name="reverse" value="transient"$trans_chk> Flüchtig
<input type="radio" name="reverse" value="persistent"$pers_chk> Dauerhaft
</p>
<p><i>Bei Rückwärtssuche für lokale Rufnummern diese Vorwahl verwenden<br>
<input type="text" name="okz" value="$okz_val"></p>
<p><i>Adresse, unter der telefon auf Port 1011 lauscht</i><br>
IP/Hostname: <input type="text" name="telefon_ip" value="$ip_val"><br>
</p>
<p>Bei <code>*</code> ist telefon von überall erreichbar. Ist keine Adresse angegeben, werden die Standardeinstellungen verwendet.<p>
<p><input type="submit" value="Speichern"></p>
</form>
EOF
