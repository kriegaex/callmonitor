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

SYSLOG='$(lang de:"System-Log" en:"system log")'
if has_package syslogd; then
    SYSLOG="<a href='pkgconf.cgi?pkg=syslogd'>$SYSLOG</a>"
fi

sec_begin '$(lang de:"Starttyp" en:"Startup type")'

cat << EOF
<p>
    <input type="radio" name="enabled" value="yes"$auto_chk id="e1">
    <label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
    <input type="radio" name="enabled" value="no"$man_chk id="e2">
    <label for="e2">$(lang de:"Manuell" en:"Manual")</label>
</p>
<p>
    <input type="hidden" name="debug" value="no">
    <input type="checkbox" name="debug" value="yes"$debug_chk id="d1">
    <label for="d1">$(lang 
	de:"mit Debug-Ausgaben" 
	en:"with debugging output"
    )</label> ($(lang de:"ins" en:"into the") $SYSLOG)
</p>
EOF

sec_end
sec_begin '$(lang de:"Status" en:"Status")'

if ! _j_is_up; then
    cat << EOF
<p>
    <strong>$(lang 
	de:"Die JFritz-Schnittstelle (Port 1012) ist nicht aktiv."
	en:"The JFritz interface (port 1012) is not active."
    )</strong>
    $(lang
	de:"Sie wird zum Betrieb des Callmonitors benötigt und kann durch
	    Wählen von <code>#96*5*</code> eingeschaltet werden."
	en:"It is required for Callmonitor's operation and can be enabled
	    by dialing <code>#96*5*</code>."
    )
</p>
EOF
else
    cat << EOF
<p>
    $(lang
	de:"Die JFritz-Schnittstelle (Port 1012) ist aktiviert. Sie kann durch
	    Wählen von <code>#96*4*</code> abgeschaltet werden."
	en:"The JFritz interface (port 1012) is active. It can be disabled by
	    dialing <code>#96*4*</code>."
    )
</p>
EOF
fi

sec_end
sec_begin '$(lang de:"Aktionen bei Anruf" en:"Actions upon calls")'

cat << EOF
<ul>
    <li><a href="/cgi-bin/file.cgi?id=listeners">$(lang
	de:"Listeners bearbeiten" en:"Edit Listeners")</a></li>
    <li><a href="/cgi-bin/extras.cgi/callmonitor/testcall">$(lang
	de:"Testanruf" en:"Test call")</a></li>
</ul>
EOF

sec_end
sec_begin '$(lang de:"Rückwärtssuche" en:"Reverse lookup")'

cat << EOF
<p>
    <input type="hidden" name="reverse" value="no">
    <input type="checkbox" name="reverse" value="yes"$reverse_chk id="r4">
    <label title="$(lang
	de:"Rufnummern wenn möglich in Namen auflösen"
	en:"Resolve numbers to names if possible"
    )" for="r4">$(lang
	de:"Rückwärtssuche durchführen"
	en:"Perform reverse lookup"
    )</label>
    ($(lang de:"bei" en:"at")
    <a href="http://www.dasoertliche.de/">DasÖrtliche</a>)
</p>
<h2>$(lang
    de:"Suchergebnis zwischenspeichern?"
    en:"Cache query result?"
)</h2>
<p>
    <input type="radio" name="reverse_cache" value="no"$no_chk id="r1">
    <label title="$(lang
	de:"Keine Speicherung der Namen"
	en:"Names are not stored"
    )" for="r1">$(lang de:"Nein" en:"No")</label>
    <input type="radio" name="reverse_cache" value="transient"$trans_chk
	id="r2">
    <label title="$(lang
	de:"Namen gehen bei nächstem Neustart verloren"
	en:"Names will be lost at the next reboot"
    )" for="r2">$(lang de:"Flüchtig" en:"Transient")</label>
    <input type="radio" name="reverse_cache" value="persistent"$pers_chk
	id="r3">
    <label title="$(lang 
	de:"Namen werden im Telefonbuch im Flash gespeichert"
	en:"Names are stored in the flash memory phone book"
    )" for="r3">$(lang de:"Dauerhaft" en:"Persistent")</label>
    (<a href="/cgi-bin/file.cgi?id=callers">$(lang 
	de:"Callers bearbeiten" en:"Edit Callers")</a>)
</p>
<h2>$(lang
    de:"Für lokale Rufnummern diese Vorwahl verwenden:"
    en:"Use this area code for local numbers:"
)</h2>
<p>
    <label for="okz">$(lang de:"Vorwahl" en:"Area code"):</label>
    <input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")"
	size="5" id="okz">
</p>
EOF

sec_end
