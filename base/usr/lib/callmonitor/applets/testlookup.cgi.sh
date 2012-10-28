require cgi
require phonebook
require reverse
require file

SELF=test
TITLE="$(lang de:"Test der Rückwärtssuche" en:"Check reverse look-up")"

eval "$(modcgi number test)"

number_val=$(html "$TEST_NUMBER")
SELECTED="<input type='checkbox' checked disabled></span>"
LEGEND="$SELECTED: $(lang
	    de:"Wird im normalen Betrieb verwendet"
	    en:"Used in actual operation"
	)"

## requires /usr/lib/callmonitor/web/reverse/lib/test_form.sh
source "$CALLMONITOR_LIBDIR/web/reverse/lib/test_form.sh"

show_test_results() {
    local number=$1 name status lkz disp unsupported= prov area_prov
    normalize_tel "$number"; number=$__
    normalize_tel "$number" display; disp=$__
    lkz=$(tel_lkz "$number")
    _reverse_choose_provider "$number"
    echo "<p style='color: gray; float: right;'>$LEGEND</p>"
    echo "<p>$(lang de:"Schlage $disp nach" en:"Looking up $disp") ...</p>"
    local type provider site label countries supported
    while readx type provider countries site label; do
	if _reverse_countries_matches "$countries" "$lkz"; then
	    supported=true
	else
	    supported=false
	fi
	local html_label="$(html "$label")"
	if [ "$site" != . ]; then
	    html_label="<a href='http://$site/' target='_blank'>$html_label</a>"
	fi
	if ! $supported; then
	    unsupported="${unsupported:+$unsupported, }$html_label"
	else 
	    local selected=
	    if [ "$provider" = "$prov" -o "$provider" = "$area_prov" ]; then
		if [ "$CALLMONITOR_REVERSE" = "yes" ]; then
		    selected=" $SELECTED"
		fi
	    fi
	    echo -n "<h2>$html_label$selected</h2>"
	    _reverse_load "$provider"
	    name=$(_reverse_lookup "$provider" "$number" 2>/dev/null); status=$?
	    local url
	    url=$(_reverse_lookup_url "$provider" "$number")
	    show_result
	fi
    done < "$CALLMONITOR_REVERSE_CFG"
    if ! empty "$unsupported"; then
	echo "<h2>$(lang de:"Andere Anbieter" en:"Other providers")</h2>"
	echo "<p>$(lang 
	    de:"Unterstützen ${lkz:++}${lkz:-$disp} nicht"
	    en:"Do not support ${lkz:++}${lkz:-$disp}"
	): $unsupported</p>"
    fi
    echo "<h2>$(lang de:"Lokale Telefonbücher" en:"Local phone books") $SELECTED</h2>"
    name=$(_pb_main --local get "$number"); status=$?; url=
    show_result
}

## uses $name, $status, and $link
show_result() {
    local a= ae=
    if [ -n "$url" ]; then
	a="<a href='$(html "$url")' target='_blank' title='$(lang de:"Überprüfen" en:"Check")'>"
	ae="</a>"
    fi
    case $status in
	0)
	    ## $(lang de:"Gefunden: " en:"Found: ")
	    echo "<pre>${a}$(html "$name")${ae}</pre>"
	;;
	1) echo "<p>${a}$(lang de:"Nicht gefunden" en:"Not found")${ae}</p>" ;;
	*) echo "<p>${a}$(lang de:"Fehler" en:"Error")${ae}</p>" ;;
    esac
}

cgi_main() {
    if let "${TEST_NUMBER+1}"; then
	cgi_begin "$TITLE ..."
	show_test_results "$TEST_NUMBER"
    else
	cgi_begin "$TITLE" extras
    fi
    new_test_form "$SELF"
    ## config_button
    cgi_end
}

cgi_main
