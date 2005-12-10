#!/bin/sh
. /usr/lib/libmodcgi.sh

remote_tel_chk='' local_tel_chk=''
case "$TELEFON_IP" in
	"") local_tel_chk=' checked' ;;
	"*") remote_tel_chk=' checked' ;;
esac

sec_begin 'Telefon-Daemon'

cat << EOF
<h2>Zugriff von auﬂen erlauben? (Port 1011)</h2>
<p>
<input type="radio" name="ip" value="*"$remote_tel_chk id="t1">
<label for="t1">Ja</label>
<input type="radio" name="ip" value=""$local_tel_chk id="t2">
<label for="t2">Nein</label>
</p>
EOF

sec_end
