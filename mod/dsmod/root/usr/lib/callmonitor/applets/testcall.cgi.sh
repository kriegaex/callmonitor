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

eval "$(modcgi source:dest:type testcall)"

normal_sel= nt_sel= end_sel=
case $TESTCALL_TYPE in
    nt) nt_sel=" selected"; TESTCALL_NT=1 ;;
    end) end_sel=" selected" TESTCALL_END=1 ;;
    normal|*) normal_sel=" selected" ;;
esac
source_val="$(httpd -e "$TESTCALL_SOURCE")"
dest_val="$(httpd -e "$TESTCALL_DEST")"

new_testcall_form() {
    cat << EOF
<form action="$SELF" method="post">
    <table><tr>
	<td><label for="type">Typ:</label> </td>
	<td>
	    <select name="type">
		<option value="normal"$normal_sel
		    title="Normaler von außen eingehender Anruf">Normal</option>
		<option value="nt"$nt_sel
		    title="Vom NT ausgehender Anruf">Vom NT</option>
		<option value="end"$end_sel
		    title="Ende eines Anrufs (experimentell)">Anruf-Ende</option>
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
    testcall -s ${TESTCALL_NT:+"-n"} ${TESTCALL_END:+"-e"} \
	"$TESTCALL_SOURCE" "$TESTCALL_DEST" |
	callmonitor-test
}

show_testcall_results() {
    echo -n "<p>Testanruf von \"$source_val\"${TESTCALL_NT:+ (NT)}"
    echo "${TESTCALL_DEST:+ an \"$dest_val\"}${TESTCALL_END:+ (Ende)}:</p>"
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
    if [ "${TESTCALL_SOURCE+set}" ]; then
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
