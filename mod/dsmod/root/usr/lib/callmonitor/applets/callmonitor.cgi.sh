##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##
require cgi
require if_jfritz_status

CHECKED=' checked'

auto_chk='' man_chk=''
case $CALLMONITOR_ENABLED in
    yes) auto_chk=$CHECKED ;;
    *) man_chk=$CHECKED ;;
esac

debug_chk=''
case $CALLMONITOR_DEBUG in
    yes) debug_chk=$CHECKED ;;
esac

reverse_chk=''
case $CALLMONITOR_REVERSE in
    yes) reverse_chk=$CHECKED
esac

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
sec_begin 'Status'

if ! _j_is_up; then
    cat << EOF
<p>
    <strong>Die Callmonitor-Schnittstelle (Port 1012) ist nicht
    aktiviert.</strong> Sie wird zum Betrieb des Callmonitors benötigt und kann
    durch Wählen von <code>#96*5*</code> eingeschaltet werden.
</p>
EOF
else
    cat << EOF
<p>
    Die Callmonitor-Schnittstelle (Port 1012) ist aktiviert. Sie kann durch
    Wählen von <code>#96*4*</code> abgeschaltet werden.
</p>
EOF
fi

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
    <label title="Rufnummern wenn möglich in Namen auflösen"
	for="r4">Rückwärtssuche durchführen</label>
    (bei <a href="http://www.dasoertliche.de/">DasÖrtliche</a>)
</p>
<h2>Suchergebnis zwischenspeichern?</h2>
<p>
    <input type="radio" name="reverse_cache" value="no"$no_chk id="r1">
    <label title="Keine Speicherung der Namen" for="r1">Nein</label>
    <input type="radio" name="reverse_cache" value="transient"$trans_chk
	id="r2">
    <label title="Namen gehen bei nächstem Neustart verloren"
	for="r2">Flüchtig</label>
    <input type="radio" name="reverse_cache" value="persistent"$pers_chk
	id="r3">
    <label title="Namen werden im Telefonbuch im Flash gespeichert"
	for="r3">Dauerhaft</label>
    (<a href="/cgi-bin/file.cgi?id=callers">Callers bearbeiten</a>)
</p>
<h2>Für lokale Rufnummern diese Vorwahl verwenden:</h2>
<p>
    <label for="okz">Vorwahl:</label>
    <input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")"
	size="5" id="okz">
</p>
EOF

sec_end
