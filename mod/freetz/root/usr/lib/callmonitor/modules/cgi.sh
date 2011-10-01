. /usr/lib/libmodcgi.sh

pre() {
    echo -n "<pre>"
    html # stdin
    echo "</pre>"
}

config_button() {
    echo "
<form class='btn' action='$(href cgi callmonitor)' method='get'>
    <div class='btn'><input type='submit' 
	value='$(lang de:"Konfiguration" en:"Configuration")'></div>
</form>
"
}

cgi_include() {
    local path=$1 file
    case $path in
	/*) ;;
	*) path="$CALLMONITOR_LIBDIR/web/$path" ;;
    esac
    if [ -d "$path" ]; then
	for file in $(ls "$path"/*); do
	    . "$file"
	done
    else
	. "$path"
    fi
}
