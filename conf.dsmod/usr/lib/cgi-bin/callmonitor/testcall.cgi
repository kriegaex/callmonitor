#!/bin/sh
. "${CALLMONITOR_CFG:=/mod/etc/default.callmonitor/system.cfg}"
require cgi

SELF=testcall
TITLE="Testanruf"

eval "$(modcgi source:dest:nt testcall)"

nt_chk="${TESTCALL_NT:+" checked"}"
source_val="$(httpd -e "$TESTCALL_SOURCE")"
dest_val="$(httpd -e "$TESTCALL_DEST")"

new_testcall_form() {
	cat << EOF
<form action="$SELF" method="post">
<table><tr>
	<td><label for="source">Quellrufnummer:</label> </td>
	<td><input type="text" name="source" id="source" value="$source_val">
	<input type="checkbox" name="nt" id="nt"$nt_chk>
	<label for="nt">vom NT</label></td>
</tr><tr>
	<td><label for="dest">Zielrufnummer:</label> </td>
	<td><input type="text" name="dest" id="dest" value="$dest_val"></td>
</tr></table>
<div class="btn"><input type="submit" value="Testanruf"></div>
</form>
EOF
}

do_testcall() {
	testcall -s ${TESTCALL_NT:+"-n"} "$TESTCALL_SOURCE" "$TESTCALL_DEST" |
		callmonitor-test
}

show_testcall_results() {
	echo -n "<p>Testanruf von \"$source_val\"${TESTCALL_NT:+ (NT)}"
	echo "${TESTCALL_DEST:+ an \"$dest_val\"}:</p>"
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
		cgi_begin "$TITLE"
	fi
	new_testcall_form
	config_button
	cgi_end
}

cgi_main
