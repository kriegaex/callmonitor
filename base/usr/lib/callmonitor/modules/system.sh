system_query() {
    local key module path
    case $SYSTEM_METHOD in
	ctl)
	    for key; do
		if [ -z "$key" ]; then echo; continue; fi
		system_split "$key"
		echo "$(ctlmgr_ctl r "$module" "$path")"
	    done
	    ;;
	webui) webui_login && webui_query "$@" ;;
    esac
}
system_update() {
    local key=$1 module path value=$2
    system_split "$key"
    case $SYSTEM_METHOD in
	ctl) ctlmgr_ctl w "$module" "$path" "$value" ;;
	webui) webui_login && webui_post_form "$key=$value" > /dev/null ;;
    esac
}
## private methods
system_split() {
    local key=$1
    module=${key%%:*}
    path=${key#*:}
}

## initialization
SYSTEM_METHOD=ctl
if ! type ctlmgr_ctl > /dev/null; then
    require webui
    SYSTEM_METHOD=webui
fi
