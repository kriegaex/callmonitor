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

SELF=testcall
TITLE="Testanruf"

eval "$(modcgi source:dest:event:event_dir testcall)"

SELECTED=" selected"

in_sel= out_sel=
case $TESTCALL_EVENT_DIR in
    in) in_sel=$SELECTED ;;
    out) out_sel=$SELECTED ;;
esac

request_sel= cancel_sel= connect_sel= disconnect_sel=
case $TESTCALL_EVENT in
    request) request_sel=$SELECTED ;;
    cancel) cancel_sel=$SELECTED ;;
    connect) connect_sel=$SELECTED ;;
    disconnect) disconnect_sel=$SELECTED ;;
esac

source_val="$(httpd -e "$TESTCALL_SOURCE")"
dest_val="$(httpd -e "$TESTCALL_DEST")"

new_testcall_form() {
    cat << EOF
<form action="$SELF" method="post">
    <table><tr>
	<td><label for="event">Ereignis:</label> </td>
	<td>
	    <select name="event_dir">
		<option value="in"$in_sel title="Eingehender Anruf">in</option>
		<option value="out"$out_sel title="Ausgehender Anruf">out</option>
	    </select>:<select name="event">
		<option value="request"$request_sel
		    title="Verbindungsanfrage (Klingeln)">request</option>
		<option value="cancel"$cancel_sel
		    title="Verbindungsanfrage abgebrochen">cancel</option>
		<option value="connect"$connect_sel
		    title="Verbindung zustandegekommen">connect</option>
		<option value="disconnect"$disconnect_sel
		    title="Verbindung beendet">disconnect</option>
	    </select>
	</td>
    </tr><tr>
	<td><label for="source">Quellrufnummer:</label> </td>
	<td>
	    <input type="text" name="source" id="source" value="$source_val">
	</td>
    </tr><tr>
	<td><label for="dest">Zielrufnummer:</label> </td>
	<td><input type="text" name="dest" id="dest" value="$dest_val"></td>
    </tr></table>
    <div class="btn"><input type="submit" value="Testanruf"></div>
</form>
EOF
}

do_testcall() {
    callmonitor-test "$TESTCALL_EVENT_DIR:$TESTCALL_EVENT" "$TESTCALL_SOURCE" "$TESTCALL_DEST" 2>&1
}

show_testcall_results() {
    echo -n "<p>Testanruf von \"$source_val\""
    echo "${TESTCALL_DEST:+ an \"$dest_val\"} [${TESTCALL_EVENT_DIR}:${TESTCALL_EVENT}]:</p>"
    do_testcall | pre
}

config_button() {
    cat <<EOF
<form class="btn" action="/cgi-bin/pkgconf.cgi" method="get">
    <input type="hidden" name="pkg" value="callmonitor">
    <div class="btn"><input type="submit" value="Zur&uuml;ck"></div>
</form>
EOF
}

cgi_main() {
    if let "${TESTCALL_SOURCE+1}"; then
	cgi_begin "$TITLE ..."
	show_testcall_results
    else
	cgi_begin "$TITLE" extras
    fi
    new_testcall_form
    config_button
    cgi_end
}

cgi_main
