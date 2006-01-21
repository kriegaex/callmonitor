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
