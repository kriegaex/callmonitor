##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2007  Andreas Bühmann <buehmann@users.berlios.de>
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
require phonebook
require reverse

SELF=testlookup
TITLE="$(lang de:"Test der Rückwärtssuche" en:"Test reverse look-up")"

eval "$(modcgi number test)"

number_val=$(html "$TEST_NUMBER")

new_test_form() {
    echo "
<form action='$SELF' method='post'>
    <table><tr>
	<td><label for='number'>$(lang
	    de:"Rufnummer" en:"Number"):</label> </td>
	<td>
	    <input type='text' name='number' id='number' value='$number_val'>
	</td>
    </tr></table>
    <div class='btn'><input type='submit' 
	value='$(lang de:"Nachschlagen" en:"Look up")'></div>
</form>
"
}

do_test() {
    callmonitor-test "$TESTCALL_EVENT_DIR:$TESTCALL_EVENT" \
	"$TESTCALL_SOURCE" "$TESTCALL_DEST" 2>&1
}

show_test_results() {
    local number=$1 name status
    number="$(echo $number | sed -e 's/[^0-9]//g')"
    normalize_tel "$number"; number=$__
    echo "<dl>"
    local type provider site label
    while read -r type provider site label; do
	echo "<dt><strong>$(html "$label")</strong></dt>"
	_reverse_load "$provider"
	echo -n "<dd>"
	name=$(_reverse_lookup "$provider" "$number"); status=$?
	case $status in
	    0) 
		echo "$(lang de:"Gefunden: " en:"Found: ")"
		echo "$name" | pre
		;;
	    1) echo "$(lang de:"Nicht gefunden. " en:"Not found. ")" ;;
	    *) echo "$(lang de:"Fehler." en:"Error.")" ;;
	esac
	echo -n "</dd>"
    done < "$REVERSE_CFG"
    echo "</dl>"
}

cgi_main() {
    if let "${TEST_NUMBER+1}"; then
	cgi_begin "$TITLE ..."
	show_test_results "$TEST_NUMBER"
    else
	cgi_begin "$TITLE" extras
    fi
    new_test_form
    config_button
    cgi_end
}

cgi_main
