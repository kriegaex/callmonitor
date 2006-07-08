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
TITLE="$(lang de:"Testanruf" en:"Test call")"

eval "$(modcgi source:dest:event:event_dir testcall)"

select "$TESTCALL_EVENT_DIR" in out
select "$TESTCALL_EVENT" request cancel connect disconnect

source_val="$(html "$TESTCALL_SOURCE")"
dest_val="$(html "$TESTCALL_DEST")"

new_testcall_form() {
    cat << EOF
<form action="$SELF" method="post">
    <table><tr>
	<td><label for="event">$(lang de:"Ereignis" en:"Event"):</label> </td>
	<td>
	    <select name="event_dir">
		<option value="in"$in_sel title="$(lang
		    de:"Eingehender Anruf" en:"Incoming call")">in</option>
		<option value="out"$out_sel title="$(lang
		    de:"Ausgehender Anruf" en:"Outgoing call")">out</option>
	    </select>:<select name="event">
		<option value="request"$request_sel title="$(lang
		    de:"Verbindungsanfrage (Klingeln)"
		    en:"Connection request (ringing)"
		)">request</option>
		<option value="cancel"$cancel_sel title="$(lang
		    de:"Verbindungsanfrage abgebrochen"
		    en:"Connection request canceled"
		)">cancel</option>
		<option value="connect"$connect_sel title="$(lang 
		    de:"Verbindung zustandegekommen"
		    en:"Connection established"
		)">connect</option>
		<option value="disconnect"$disconnect_sel title="$(lang
		    de:"Verbindung beendet"
		    en:"Connection terminated"
		)">disconnect</option>
	    </select>
	</td>
    </tr><tr>
	<td><label for="source">$(lang
	    de:"Quellrufnummer" en:"Source number"):</label> </td>
	<td>
	    <input type="text" name="source" id="source" value="$source_val">
	</td>
    </tr><tr>
	<td><label for="dest">$(lang
	    de:"Zielrufnummer" en:"Destination number"):</label> </td>
	<td><input type="text" name="dest" id="dest" value="$dest_val"></td>
    </tr></table>
    <div class="btn"><input type="submit" 
	value="$(lang de:"Testanruf" en:"Test call")"></div>
</form>
EOF
}

do_testcall() {
    callmonitor-test "$TESTCALL_EVENT_DIR:$TESTCALL_EVENT" \
	"$TESTCALL_SOURCE" "$TESTCALL_DEST" 2>&1
}

show_testcall_results() {
    echo -n "<p>$(lang de:"Testanruf von" en:"Test call from") \"$source_val\""
    echo "${TESTCALL_DEST:+ $(lang de:"an" en:"to") \"$dest_val\"}" \
	"[${TESTCALL_EVENT_DIR}:${TESTCALL_EVENT}]:</p>"
    do_testcall | pre
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
