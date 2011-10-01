## requires /usr/lib/callmonitor/applets/testlookup.cgi.sh
case $PATH_INFO in
    /test)
	source "$CALLMONITOR_LIBDIR/applets/testlookup.cgi.sh"
	exit
	;;
esac

require cgi
require tel
require file
require hash
require url
require webui
require reverse_config

source "$CALLMONITOR_LIBDIR/web/reverse/lib/test_form.sh"

SELF=reverse
TITLE='$(lang
    de:"Konfiguration der Rückwärtssuche"
    en:"Reverse-lookup configuration"
)'
PARAMS="area:save"
for lkz in $LKZ_LIST; do
    PARAMS="$PARAMS:full_$lkz"
done
## requires /usr/lib/callmonitor/reverse/country.cfg
COUNTRIES="$CALLMONITOR_LIBDIR/reverse/country.cfg"

eval "$(modcgi "$PARAMS" reverse)"

if [ -n "$REVERSE_SAVE" ]; then
    new_provider=
    for lkz in $LKZ_LIST; do
       eval "new_provider=\"\$new_provider $lkz:\$REVERSE_FULL_$lkz\""
    done
    new_provider=${new_provider# }

    ## delegate to Freetz saving mechanism
    PATH_INFO=/callmonitor webui_post_form_generic /usr/mww/cgi-bin/conf \
    	"reverse_provider=$(urlencode "$new_provider")&area_provider=$(urlencode "$REVERSE_AREA")"
    exit $?
fi

new_hash country
while readx lkz country; do 
    country_put "$lkz" "$country"
done < $COUNTRIES

select "$AREA_PROVIDER" :null

cgi_begin "$TITLE"

echo "<form action='$SELF' method='post'>"

sec_begin '$(lang de:"Anbieter für vollständige Rufnummern" en:"Providers for complete numbers")'

select_fullprovider() {
    local lkz=$1 name="?"
    if country_contains "$lkz"; then
	country_get "$lkz" name
    fi
    echo "<tr><td>$(html "$name")</td><td>+$lkz</td>"
    echo "<td>"
    REVERSE_PROVIDER_get "$lkz" selected
    echo "<select name='full_$lkz'>"
    list_providers R "$lkz" "$selected"
    echo "</select>"
    echo "</td></tr>"
}

list_providers() {
    local match=$1 lkz=$2 selected=$3 type provider site label sel countries
    while readx type provider countries site label; do
	case $type in
	    $match*) ;;
	    *) continue ;;
	esac
	case ",$countries," in
	    *",$lkz,"*|*",$lkz!,"*) ;;
	    *) continue ;;
	esac
	if [ "$selected" = "$provider" ]; then
	    sel=" selected"
	else
	    sel=
	fi
	echo "<option title='$site' value='$provider'$sel>$label</option>"
    done < "$CALLMONITOR_REVERSE_CFG"
}

echo "
<table width='100%'>
    <colgroup>
	<col width='25%' span='2'>
	<col width='50%'>
    </colgroup>
"
for lkz in $LKZ_LIST; do
	select_fullprovider "$lkz"
done
echo "
</table>
"

sec_end

sec_begin '$(lang de:"Anbieter für Vorwahlen" en:"Providers for prefixes")'
echo "
<table width='100%'>
    <colgroup>
	<col width='50%' span='2'>
    </colgroup>
<tr><td>
    <label for='area'>$(lang 
	de:"Notfalls Vorwahl nachschlagen bei"
	en:"Alternatively lookup area code at")</label>
</td><td>
    <select name='area' id='area'>
	<option title='Keine Auflösung von Vorwahlen'
	    value=''$null_sel>$(lang de:"niemandem" en:"nowhere")</option>
"
list_providers A "*" "$AREA_PROVIDER"
echo "
    </select>
    </td></tr>
</table>
"

sec_end

echo "<div class='btn'><input type='submit' value='$(lang de:"Übernehmen" en:"Apply")' name='save'></div>"
echo "</form>"

sec_begin "$(lang de:"Test" en:"Check")"

new_test_form "$SELF/test"

sec_end


cgi_end
