require webui

config() {
    local type=query key value extra=
    case $1 in
	forward)
	    key="forwardrules:settings/rule$((${2:-1}-1))/activated"
	    if ? "${3:+1}"; then
		type=post value="$(_c_value "$3" "$1" "$2")"
	    fi
	    ;;
	wlan)
	    case $2 in
		2*|"") key="wlan:settings/ap_enabled" ;;
		5*) key="wlan:settings/ap_enabled_scnd" ;;
		on|yes|true|1|off|no|false|0|toggle)
		    ## switch both; query 2.4 only (see above: "")
		    shift # wlan
		    config wlan 2.4 "$@"
		    config wlan 5 "$@"
		    return
		    ;;
		*) echo "Syntax error: $*" >&2; return 1 ;;
	    esac
	    if ? "${3:+1}"; then
		type=post value="$(_c_value "$3" "$1" "$2")"
	    fi
	    ;;
	dect)
	    key="dect:settings/enabled"
	    if ? "${2:+1}"; then
		type=post value="$(_c_value "$2" "$1")"
	    fi
	    ;;
	sip)
	    key="sip:settings/sip$((${2:-1}-1))/activated"
	    if ? "${3:+1}"; then
		type=post value="$(_c_value "$3" "$1" "$2")"
	    fi
	    ;;
	diversion)
	    key="telcfg:settings/Diversity$((${2:-1}-1))/Active"
	    extra="telcfg:settings/RefreshDiversity"
	    if ? "${3:+1}"; then
		type=post value="$(_c_value "$3" "$1" "$2")"
	    fi
	    ;;
	*)
	    type=fail
	    ;;
    esac
    case $type in
	post) webui_login; webui_post_form "$key=$value" > /dev/null ;;
	query) webui_login; echo $(_c_f_boolean $(webui_query "$extra" "$key" | tail +2)) ;;
	fail) echo "Unknown configuration '$1'" >&2; return 1 ;;
    esac
}

pushservice() {
    webui_login; webui_post_form "emailnotify:settings/TestMail=1" > /dev/null
}

_c_boolean() {
    case $1 in
	on|yes|true|1) echo "1" ;;
	off|no|false|0) echo "0" ;;
    esac
}
_c_f_boolean() {
    case $1 in
	1) echo "on" ;;
	0) echo "off" ;;
	*) echo "error" ;;
    esac
}
_c_value() {
    local val=$1
    case $1 in
	toggle)
	    shift
	    case $(config "$@") in
		on)  val=off ;;
		off) val=on ;;
	    esac
	    ;;
    esac
    _c_boolean "$val"
}

