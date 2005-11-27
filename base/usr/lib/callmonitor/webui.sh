require net

WEBCM="/usr/www/html/cgi-bin/webcm"

webui_post_form() (
	cd "$(dirname "$WEBCM")"
	local POST_DATA="$1"
	echo -n "$POST_DATA" |
	REQUEST_METHOD="POST" \
	REMOTE_ADDR="127.0.0.1" \
	CONTENT_TYPE="application/x-www-form-urlencoded" \
	CONTENT_LENGTH=${#POST_DATA} \
	$WEBCM
)
webui_get() (
	cd "$(dirname "$WEBCM")"
	REQUEST_METHOD="GET" \
	REMOTE_ADDR="127.0.0.1" \
	QUERY_STRING="$1" \
	$WEBCM
)
webui_login() {
	webui_post_form "login:command/password=$(urlencode "$(webui_password)")" \
	> /dev/null
}

webui_config() {
	allcfgconv -C ar7 -c -o - | 
	sed -ne '/^webui {/,/^}/{/=/{s/ *= */=/;s/^[ 	]*//;p}}'
}
webui_password() {
	local password=
	eval "$(webui_config | grep '^password=')"
	echo "$password"
}
