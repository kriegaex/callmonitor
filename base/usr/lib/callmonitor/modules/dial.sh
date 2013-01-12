require webui
require url

dial() {
    local number=$1 port=$2
    _dial_port "$port" "telcfg:command/Dial=$(urlencode "$number")"
}

hangup() {
    local port=$1
    _dial_port "$port" "telcfg:command/Hangup"
}

_dial_port() {
    local port=$1 data=$2
    if ! empty "$port"; then
	data="telcfg:settings/DialPort=$(urlencode "$port")&$data"
    fi
    { webui_login && webui_post_form "$data"; } > /dev/null 2>&1
}
