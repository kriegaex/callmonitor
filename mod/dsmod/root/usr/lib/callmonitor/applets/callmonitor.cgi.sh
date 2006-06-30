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
SELECTED=' selected'

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

no_sel='' trans_sel='' pers_sel=''
case "$CALLMONITOR_REVERSE_CACHE" in
    no) no_sel=$SELECTED ;;
    transient) trans_sel=$SELECTED ;;
    persistent) pers_sel=$SELECTED ;;
esac

oert_sel='' werdran_sel='' invers_sel=''
case "$CALLMONITOR_REVERSE_PROVIDER" in
    dasoertliche) oert_sel=$SELECTED ;;
    weristdran) werdran_sel=$SELECTED ;;
    inverssuche) invers_sel=$SELECTED ;;
esac

SYSLOG='$(lang de:"System-Log" en:"system log")'
if has_package syslogd; then
    SYSLOG="<a href='pkgconf.cgi?pkg=syslogd'>$SYSLOG</a>"
fi

read CALLMONITOR_VERSION < /mod/etc/default.callmonitor/.version

sec_begin '$(lang de:"Starttyp" en:"Startup type")'

cat << EOF
<div style="float: right;"><a href="$CALLMONITOR_FORUM_URL">Version
    $CALLMONITOR_VERSION</a></div>
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

if ! _j_is_up; then
sec_begin '$(lang de:"Status" en:"Status")'
cat << EOF
<ul>
    <li><strong style="color: red">$(lang 
	de:"Die CallMonitor-Schnittstelle (Port 1012) ist nicht aktiv."
	en:"The CallMonitor interface (port 1012) is not active."
    )</strong>
    $(lang
	de:"Sie wird zum Betrieb des Callmonitors benötigt."
	en:"It is required for Callmonitor's operation."
    ) [<a href="extras.cgi/callmonitor/exec?jfritz=on">$(lang
	de:"Einschalten" en:"Enable"
    )</a>]
    </li>
</ul>
EOF
sec_end
fi

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
    <label for="provider">$(lang de:"bei" en:"at")</label>
    <select name="reverse_provider" id="provider">
	<option title="www.dasoertliche.de"
	    value="dasoertliche"$oert_sel>DasÖrtliche</option>
	<option title="wer-ist-dran.de"
	    value="weristdran"$werdran_sel>Wer ist dran? (ABIS)</option>
	<option title="www.inverssuche.de"
	    value="inverssuche"$invers_sel>inverssuche.de</option>
    </select>
</p>
<p>
    <label for="cache">$(lang
	de:"Suchergebnisse zwischenspeichern?"
	en:"Cache query results?"
    )</label>
    <select name="reverse_cache" id="cache">
	<option title="$(lang
	    de:"Keine Speicherung der Namen"
	    en:"Names are not stored"
	)" value="no"$no_sel>$(lang de:"Nein" en:"No")</option>
	<option title="$(lang
	    de:"Namen gehen bei nächstem Neustart verloren"
	    en:"Names will be lost at the next reboot"
	)" value="transient"$trans_sel>$(lang
	    de:"Flüchtig" en:"Transiently")</option>
	<option title="$(lang 
	    de:"Namen werden im Telefonbuch im Flash gespeichert"
	    en:"Names are stored in the flash memory phone book"
	)" value="persistent"$pers_sel>$(lang
	    de:"Dauerhaft" en:"Persistently")</option>
    </select>
    [<a href="/cgi-bin/file.cgi?id=callers">$(lang 
	de:"Callers&nbsp;bearbeiten" en:"Edit&nbsp;Callers")</a>]
</p>
<p>
    <label for="okz">$(lang
	de:"Vorwahl für lokale Rufnummern"
	en:"Area code for local numbers"
    ):</label>
    <input type="text" name="okz" value="$(httpd -e "$CALLMONITOR_OKZ")"
	size="5" id="okz">
</p>
EOF

sec_end
