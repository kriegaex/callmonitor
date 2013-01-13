require user

for once in my_life; do ## ;-) to allow "break"ing

user_supported || break
# user_is_compat && break
# user_auth_is_skipped && break

sec_begin '$(lang de:"Zugangsdaten" en:"Credentials")'

echo "
<p>
$(lang 
    de:"Für den Zugriff auf die AVM-Weboberfläche im Mehrbenutzermodus (Anmeldung mit FRITZ!Box-Benutzernamen und Kennwort)"
    en:"For accessing the AVM web interface in multi-user mode"
)
</p>
<p>
<label for='username'>$(lang de:"Benutzername" en:"Username"):</label>
<select name='username' id='username'>
"
{ user_list; echo "$CALLMONITOR_USERNAME"; } | sort -u | 
while read -r name; do
    [ "$name" = "@CompatMode" ] && continue
    name_h=$(html "$name")
    unset name_sel
    if [ "$name" = "$CALLMONITOR_USERNAME" ]; then
	name_sel=" selected"
    fi
    echo "<option value='$name_h'$name_sel>$name_h</option>"
done
echo "
</select>
</p>
"

sec_end

done
