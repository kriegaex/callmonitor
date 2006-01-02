#!/bin/sh
. /usr/lib/libmodcgi.sh
. "${CALLMONITOR_CFG:=/mod/etc/default.callmonitor/system.cfg}"

SELF=maint
TITLE='Callmonitor-Wartung'

cmd_button() {
	local cmd="$1" label="$2" method="post"
	if [ -z "$cmd" ]; then
		method="get"
	fi
	cat << EOF
<div class="btn"><form class="btn" action="$SELF" method="$method"><input name="cmd" value="$1" type="hidden"><input value="$2" type="submit"></form></div>
EOF
}

eval "$(modcgi cmd maint)"

if [ -n "$MAINT_CMD" ]; then
	cgi_begin 'Callmonitor-Wartung ...'
	case "$MAINT_CMD" in
		tidy)
			echo "<p>Räume Callers auf:</p>"
			echo -n "<pre>"
			httpd -e "$(phonebook tidy 2>&1)"
			echo "</pre>"
			;;
		*)
			echo "<p>Unbekannter Befehl</p>"
			;;
	esac
	cmd_button '' 'Zurück'
	cgi_end
	exit
fi

cgi_begin 'Callmonitor-Wartung' extras
sec_begin 'Callers'

let LINES="$({ 
	grep '[[:print:]]' "$CALLMONITOR_PERSISTENT" | wc -l; } 2>/dev/null)+0"
let BYTES="$(wc -c < "$CALLMONITOR_PERSISTENT" 2>/dev/null)+0"
if [ $BYTES -lt 2048 ]; then
	SIZE="$BYTES B"
else
	SIZE="$(($BYTES/1024)) KB"
fi

cat << EOF
<p>$LINES Einträge (Größe: $SIZE)
	<a href="/cgi-bin/file.cgi?id=callers">bearbeiten</a></p>
<p>Beim Aufräumen werden die Einträge im Telefonbuch sortiert und Leerzeilen
entfernt.</p>
EOF
cmd_button tidy 'Aufräumen'
sec_end
cgi_end
