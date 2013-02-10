require user

for once in my_life; do ## ;-) to allow "break"ing

user_supported || break
compat=false
user_is_compat && compat=true
skipped=false
user_auth_is_skipped && skipped=true

sec_begin '$(lang de:"Zugangsdaten" en:"Credentials")'

echo "<p>$(lang
    de:"Der Callmonitor greift für bestimmte Funktionalitäten auf die AVM-Weboberfläche zu und muss sich dort einloggen können."
    en:"The Callmonitor accesses the AVM web interface for certain functionalities and must be able to log in."
)</p>"

echo "<p>$(lang de:"Aktuell gewählter Modus" en:"Currently selected mode"): "
if $skipped; then
    echo "$(lang de:"Kein Passwort" en:"No password")"
elif $compat; then
    echo "$(lang de:"Einzelbenutzer" en:"Single-user")"
else
    echo "$(lang de:"Mehrbenutzer" en:"Multi-user")"
fi
echo "</p>"

echo "
<p>
<label for='username'>$(lang de:"Benutzername im Mehrbenutzer-Modus" en:"Username in multi-user mode"):</label>
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
