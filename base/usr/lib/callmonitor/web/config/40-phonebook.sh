require webui
require tel
source /usr/lib/libmodredir.sh

check "$CALLMONITOR_REVERSE" yes:reverse
select "$CALLMONITOR_REVERSE_CACHE" no transient:trans persistent:pers
check "$CALLMONITOR_READ_FONBUCH" yes:fon
check "$CALLMONITOR_PHONEBOOKS" "callers cache avm":after "avm callers cache":before

echo '
<script type="text/javascript">
    function dep(father, child) {
	document.getElementById(child).disabled = ! father.checked;
    }
    dep.init = function() {
	for (var i = 0; i < document.forms.length; i++) {
	    var f = document.forms[i];
	    for (var j = 0; j < f.elements.length; j++) {
		var e = f.elements[j];
		if (e.onchange) e.onchange();
	    }
	}
    }

    var oldonload = window.onload;
    window.onload = function() {
	if (oldonload) oldonload();
	dep.init();
    }
</script>
'

sec_begin '$(lang de:"Standortangaben" en:"Location data")'

echo "
<table width='100%'>
    <colgroup>
	<col width='25%'>
	<col width='75%'>
    </colgroup>
<tr>
    <td>$(lang de:"Landesvorwahl" en:"Country code")</td>
    <td><input disabled size="3" value='$(html "$LKZ_PREFIX")'>
	<input disabled size="4" value='$(html "$LKZ")'></td>
</tr>
<tr>
    <td>$(lang de:"Ortsvorwahl" en:"Area code")</td>
    <td><input disabled size="3" value='$(html "$OKZ_PREFIX")'>
	<input disabled size="4" value='$(html "$OKZ")'></td>
</tr>
</table>
"

sec_end

sec_begin '$(lang de:"Rückwärtssuche" en:"Reverse lookup")'

H_CALLERS="<a href='$(href file callmonitor callers)'>$(lang 
	de:"Callmonitor-Telefonbuch"
	en:"Callmonitor's phone book"
    )</a>"

echo "
<table>
<tr>
    <td><input type='checkbox' name='dummy' checked disabled></td>
    <td>$(lang de:"In" en:"Lookup in") $H_CALLERS
	$(lang de:"nachschlagen" en:"")</td>
</tr>
<tr>
    <td><input type='hidden' name='read_fonbuch' value='no'><!--
    --><input type='checkbox' name='read_fonbuch' value='yes'$fon_chk id='r5'
	onchange='dep(this,\"prio\")'></td>
    <td><label for='r5'>$(lang
	de:"Im FRITZ!Box-Telefonbuch nachschlagen"
	en:"Lookup in FRITZ!Box's phone book"
    )</label></td>
    <td><input type='hidden' name='phonebooks' value='callers cache avm'><!--
    --><input type='checkbox' name='phonebooks' value='avm callers cache'$before_chk id='prio'></td>
    <td><label for='prio'>$(lang
	de:"vor Callmonitor-Telefonbuch"
	en:"before Callmonitor's phone book"
    )</label></td>
</tr>
"
H_PROVIDERS="<a href='$(href extra callmonitor reverse)' title='$(lang
	de:"Rückwärtssucheseiten im Web"
	en:"Reverse-lookup Web sites"
    )'>$(lang de:"externen Anbietern" en:"external providers")</a>"
echo "
<tr>
    <td><input type='hidden' name='reverse' value='no'><!--
    --><input type='checkbox' name='reverse' value='yes'$reverse_chk id='r4'
    $(
	[ "$CALLMONITOR_EXPERT" = yes ] && echo "onchange='dep(this,\"cache\")'"
    )></td>
    <td><label title='$(lang
	de:"Rufnummern wenn möglich in Namen auflösen"
	en:"Resolve numbers to names if possible"
    )' for='r4'>$(lang
	de:"Rückwärtssuche"
	en:"Perform reverse lookup"
    )</label> $(lang
	de:"bei $H_PROVIDERS durchführen"
	en:"at $H_PROVIDERS"
    )</td>
</tr>
"
if [ "$CALLMONITOR_EXPERT" = yes ]; then
    echo "
    <tr><td></td>
	<td><label for='cache'>$(lang
	    de:"Suchergebnisse zwischenspeichern?"
	    en:"Cache query results?"
	)</label></td>
	<td colspan="0"><select name='reverse_cache' id='cache'>
	    <option title='$(lang
		de:"Keine Speicherung der Namen"
		en:"Names are not stored"
	    )' value='no'$no_sel>$(lang de:"Nein" en:"No")</option>
	    <option title='$(lang
		de:"Namen gehen bei nächstem Neustart verloren"
		en:"Names will be lost at the next reboot"
	    )' value='transient'$trans_sel>$(lang
		de:"Flüchtig" en:"Transiently")</option>
	    <option title='$(lang 
		de:"Namen werden im Telefonbuch des Callmonitors gespeichert"
		en:"Names are stored in Callmonitor's phone book"
	    )' value='persistent'$pers_sel>$(lang
		de:"Dauerhaft" en:"Persistently")</option>
	</select></td>
    </tr>
    "
fi
echo "
</table>
"

sec_end
