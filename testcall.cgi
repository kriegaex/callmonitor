#!/bin/sh
. /usr/lib/libmodcgi.sh

eval "$(modcgi source:target:nt testcall)"

nt_chk="${TESTCALL_NT:+" checked"}"
source_val="$(httpd -e "$TESTCALL_SOURCE")"
target_val="$(httpd -e "$TESTCALL_TARGET")"

new_testcall_form() {
	cat <<EOF
<form action="/cgi-bin/testcall.cgi" method="post">
<table><tr>
	<td><label for="source">Quellrufnummer:</label> </td>
	<td><input type="text" name="source" id="source" value="$source_val">
	<input type="checkbox" name="nt" id="nt"$nt_chk>
	<label for="nt">vom NT</label></td>
</tr><tr>
	<td><label for="target">Zielrufnummer:</label> </td>
	<td><input type="text" name="target" id="target" value="$target_val"></td>
</tr></table>
<div class="btn"><input type="submit" value="Testanruf"></div>
</form>
EOF
}

do_testcall() {
	testcall -s ${TESTCALL_NT:+"-n"} "$TESTCALL_SOURCE" "$TESTCALL_TARGET" |
		callmonitor-test
}

show_testcall_results() {
	echo -n "<p>Testanruf von \"$source_val\"${TESTCALL_NT:+ (NT)}"
	echo "${TESTCALL_TARGET:+ an \"$target_val\"}:</p>"
	echo -n '<pre>'
	do_testcall
	echo '</pre>'
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
	cgi_begin 'Testanruf...'
	if [ "${TESTCALL_SOURCE+set}" ]; then
		show_testcall_results
	fi
	new_testcall_form
	config_button
	cgi_end
}

if [ "$1" = "form" ]; then
	new_testcall_form
else
	cgi_main
fi
