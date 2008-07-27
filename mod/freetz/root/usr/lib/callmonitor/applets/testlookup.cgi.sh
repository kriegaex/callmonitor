##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2008  Andreas Bühmann <buehmann@users.berlios.de>
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
require file

SELF=testlookup
TITLE="$(lang de:"Test der Rückwärtssuche" en:"Check reverse look-up")"

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

show_test_results() {
    local number=$1 name status lkz disp
    normalize_tel "$number"; number=$__
    normalize_tel "$number" display; disp=$__
    lkz=$(tel_lkz "$number")
    echo "<p>$(lang de:"Schlage $disp nach" en:"Looking up $disp") ...</p>"
    echo "<dl>"
    local type provider site label countries
    while readx type provider countries site label; do
	echo "<dt><strong><a href="http://$site/">$(html "$label")</a></strong></dt>"
	echo -n "<dd>"
	case ",$countries," in
	    *",$lkz,"*|*",$lkz!,"*|*",*,") ;;
	    *)
		echo "$(lang 
		    de:"Unterstützt +$lkz nicht."
		    en:"Does not support +$lkz."
		)"
		continue
		;;
	esac
	_reverse_load "$provider"
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
    done < "$CALLMONITOR_REVERSE_CFG"
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
