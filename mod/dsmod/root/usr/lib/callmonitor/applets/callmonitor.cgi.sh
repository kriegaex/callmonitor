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

fifo_chk='' jfritz_chk=''
case "$CALLMONITOR_INTERFACE" in
    fifo) fifo_chk=$CHECKED ;;
    jfritz) jfritz_chk=$CHECKED ;;
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
    <label for="r4" title="Rufnummern wenn möglich in Namen
	auflösen">Rückwärtssuche durchführen</label>
    (bei <a href="http://www.dasoertliche.de/">DasÖrtliche</a>)
</p>
<p>
    <label for="okz">Vorwahl für lokale Rufnummern:</label>
    <input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")"
	size="5" id="okz">
</p>
<h2>Suchergebnis zwischenspeichern?</h2>
<p>
    <input type="radio" name="reverse_cache" value="no"$no_chk id="r1">
    <label for="r1" title="Keine Speicherung der Namen">Nein</label>
    <input type="radio" name="reverse_cache" value="transient"$trans_chk
	id="r2">
    <label for="r2" title="Namen gehen bei nächstem Neustart
	verloren">Flüchtig</label>
    <input type="radio" name="reverse_cache" value="persistent"$pers_chk
	id="r3">
    <label for="r3" title="Namen werden im Telefonbuch im Flash
	gespeichert">Dauerhaft</label>
    (<a href="/cgi-bin/file.cgi?id=callers">Callers bearbeiten</a>)
</p>
EOF

sec_end
sec_begin 'Schnittstelle'

cat << EOF
<h2>Technik zum Abruf der Anrufinformationen vom telefon-Daemon</h2>
<p>
    <input type="radio" name="interface" value="jfritz"$jfritz_chk id="i1">
    <label for="i1">TCP: Aktivierbar per <code>#96*5*</code> am Telefon
    (empfohlen)</label><br>
    <input type="radio" name="interface" value="fifo"$fifo_chk id="i2">
    <label for="i2">Pipe (Debug-Ausgabe)</label>
</p>
EOF
sec_end
