#!/bin/sh
auto_chk=''; man_chk=''

if [ "$CALLMONITOR_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

cat << EOF
<h1>Call-Monitor-Konfiguration</h1>
<form action="/cgi-bin/save.cgi?form=pkg_callmonitor" method="post">
<p><i>Startverhalten von callmonitor beim Bootvorgang</i><br>
<input type="radio" name="enabled" value="yes"$auto_chk> Automatisch
<input type="radio" name="enabled" value="no"$man_chk> Manuell</p>
<p><input type="submit" value="Speichern"></p>
</form>
EOF
