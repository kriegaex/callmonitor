require system
require url
require user

webui_post_form_generic() {
    local cgi=$1 post_data=$2
    echo -n "$post_data" |
    REQUEST_METHOD=POST REMOTE_ADDR=${REMOTE_ADDR-127.0.0.1} \
    WEBDIR_PATH=/usr/www/html \
    CONTENT_TYPE=application/x-www-form-urlencoded \
    CONTENT_LENGTH=${#post_data} \
    "$cgi"
}

WEBCM_DIR=/usr/www/html/cgi-bin
WEBCM=$WEBCM_DIR/webcm

LUACGI_DIR=/usr/www/all/cgi-bin
LUACGI=$LUACGI_DIR/luacgi

## Firmware version xx.04.74 introduces session IDs
##
## The session ID will be held in the environment variable WEBUI_SID
## and be used transparently by functions such as webui_get and 
## webui_post_form.
##
## webui_login and webui_logout start and terminate a session, respectively.
## If a firmware is used that does not support SIDs, webui_login falls back
## to the old login technique (and webui_logout is a no-op).
##
## See also: AVM Technical Note, Session IDs und geändertes Login-Verfahren im
## FRITZ!Box Webinterface, 
## http://www.avm.de/de/Extern/Technical_Note_Session_ID.pdf
##
## A login is deemed valid until the timestamp in WEBUI_EXPIRES is reached
## (last login + WEBUI_LIFETIME seconds).
## 
## Fritz!OS 5.50 introduces multi-user support, see 
## http://www.avm.de/de/Extern/files/session_id/AVM_Technical_Note_-_Session_ID.pdf
## WEBUI_TYPE is used to remember which login method was used

## Convert login_sid.xml to shell variables
##
## <?xml version="1.0" encoding="utf-8"?>
## <SessionInfo>
## <iswriteaccess><? echo $var:iswriteaccess ?></iswriteaccess>
## <SID><? echo $var:sid ?></SID>
## <Challenge><? query security:status/challenge ?></Challenge>
## </SessionInfo>
##
## Login information may be passed as a parameter to minimize the number of
## requests
##
webui_login_sid() {
    [ -e "/var/html/html/login_sid.xml" ] || return 1
    local info=$(webui_post_form "${1:+$1&}getpage=../html/login_sid.xml")
    case $info in
    	*SessionInfo*)
	    local _ key value
	    echo "$info" | while IFS="<>" read -r _ key value _; do
		case $key in
		    iswriteaccess|SID|Challenge)
		    	echo "$key='$value'"
		    ;;
		esac
	    done
	    return 0
	;;
	*) return 2 ;;
    esac
}
## Similar handling of login_sid.lua (TODO: Merge?)
webui_login_sid_lua() {
    [ -e "/var/html/login_sid.lua" ] || return 1

    ## Check for "skip_auth_from_homenetwork"-option, an option available since
    ## AVM completely switched to the lua-based web server.
    ## A simple check for "/var/html/login_sid.lua" is not enough. Some firmware
    ## versions "in-between" like e.g. 7170.04.88, *.05.2x and even some *.05.5x
    ## contain both "/var/html/login_sid.lua" and "/var/html/html/login_sid.xml".
    ## The logic below is shamelessly stolen from LCR-Updater by Harald Becker.
    ## A possible alternative would be to check /etc/.version and fallback to
    ## the non-lua-based method if the value it contains is smaller than 05.50.
    [ "$SYSTEM_METHOD" = "webui" ] && return 1
    [ -z "$(system_query boxusers:settings/skip_auth_from_homenetwork)" ] && return 1

    local info=$(webui_post_lua "${1:+$1&}script=/login_sid.lua")
    ## echo "$info" >&2
    case $info in
    	*SessionInfo*)
	    local _ key value
	    echo "$info" | sed -r "s#(<(SessionInfo|Rights)>|</[^>]*>)#\1\n#g" |
	    while IFS="<>" read -r _ key value _; do
		## echo "|$key| => |$value|" >&2
		case $key in
		    SID|Challenge)
		    	echo "$key='$value'"
		    ;;
		esac
	    done
	    return 0
	;;
	*) return 2 ;;
    esac
}

WEBUI_LIFETIME=120

## Login (and obtain a session id)
webui_login() {
    local now=$(date +%s) expires=${WEBUI_EXPIRES:-0} status
    [ "$now" -lt "$expires" ] && return
    
    webui_login_do; status=$?

    let WEBUI_EXPIRES="now + WEBUI_LIFETIME"
    return $status
}
webui_login_do() {
    local username password sinfo
    ## Try out login methods one after another
    sinfo=$(webui_login_sid_lua)
    if [ $? -eq 0 ]; then
	## echo "multi-user" >&2
	## multi-user, >= FRITZ!OS 5.50
	webui_set_credentials
	local SID Challenge
	## echo "$sinfo" >&2
	eval "$sinfo"
	case $(webui_sid_type "$SID") in
	    invalid)
		## we are being challenged; respond and (hopefully) receive a SID
		local response=$(webui_response "$Challenge" "$password")
		unset SID Challenge
		sinfo=$(webui_login_sid_lua "username=$username&response=$response") &&
		eval "$sinfo"
		## echo "$sinfo" >&2
		;;
	    valid) 
		# already logged in 
		;;
	    error) echo "Malformed SID" >&2 ;;
	esac
	WEBUI_SID=$SID
	WEBUI_TYPE=multiuser
	case $(webui_sid_type "$SID") in
	    valid) return 0 ;;
	    invalid) return 1 ;;
	    error) return 2 ;;
	esac
    fi
    sinfo=$(webui_login_sid)
    if [ $? -eq 0 ]; then
	## simple session ID
	local iswriteaccess SID Challenge
	password=$(webui_password)
	eval "$sinfo"
	if [ ${iswriteaccess:-0} -eq 0 ]; then

    	    ## we are being challenged; respond and (hopefully) receive a SID
	    local response=$(webui_response "$Challenge" "$password")
	    unset iswriteaccess SID Challenge
	    sinfo=$(webui_login_sid "login:command/response=$response") &&
		eval "$sinfo"
	fi
	WEBUI_SID=$SID
	WEBUI_TYPE=sid
	case $(webui_sid_type "$SID") in
	    valid) return 0 ;;
	    invalid) return 1 ;;
	    error) return 2 ;;
	esac
    fi
    if true; then
	## old login
	unset WEBUI_SID
	password=$(webui_password)
	if ! empty "$password"; then
	    webui_post_form "login:command/password=$(urlencode "$password")" \
	    > /dev/null
	fi
	WEBUI_TYPE=classic
	return 0 ## even if login fails (detecting that case is not easy)
    fi
}
webui_response() {
    local challenge=$1 password=$2
    local md5="$(echo -n "$challenge-$password" |
	sed -e 's/./&\n/g' | tr '\n' '\0' | md5sum)"
    md5=${md5%% *}
    local response="$challenge-$md5"
    echo "$response"
}
webui_sid_type() {
    local sid=$1
    case $sid in
	0000000000000000) echo "invalid" ;;
	????????????????) echo "valid" ;;
	*) echo "error" ;;
    esac
}

## Terminate the current session
webui_logout() {
    if ! empty "$WEBUI_SID"; then
	case $WEBUI_TYPE in
	    multiuser) webui_login_sid_lua "logout=" > /dev/null ;;
	    sid) webui_post_form "security:command/logout=" > /dev/null ;;
	esac
	unset WEBUI_SID
    fi
    unset WEBUI_EXPIRES
}

webui_post_form() (
    cd "$WEBCM_DIR"
    local post_data="${WEBUI_SID:+sid=$WEBUI_SID&}$1" REMOTE_ADDR=${CALLMONITOR_REMOTE_ADDR:-127.0.0.1}
    webui_post_form_generic "$WEBCM" "$post_data"
)
webui_get() (
    cd "$WEBCM_DIR"
    REQUEST_METHOD=GET REMOTE_ADDR=${CALLMONITOR_REMOTE_ADDR:-127.0.0.1} \
    WEBDIR_PATH=/usr/www/html \
    QUERY_STRING="${WEBUI_SID:+sid=$WEBUI_SID&}$1" "$WEBCM"
)

webui_post_lua() (
    cd "$LUACGI_DIR"
    local post_data="${WEBUI_SID:+sid=$WEBUI_SID&}$1" REMOTE_ADDR=${CALLMONITOR_REMOTE_ADDR:-127.0.0.1}
    webui_post_form_generic "$LUACGI" "$post_data"
)
webui_get_lua() {
    cd "$LUACGI_DIR"
    REQUEST_METHOD=GET REMOTE_ADDR=${CALLMONITOR_REMOTE_ADDR:-127.0.0.1} \
    WEBDIR_PATH=/usr/www/html \
    QUERY_STRING="${WEBUI_SID:+sid=$WEBUI_SID&}$1" "$LUACGI"
}

## requires /usr/bin/cfg2sh
webui_config() {
    cfg2sh ar7 webui
}

## cache password (not multi-user)
unset WEBUI_PASSWORD
webui_password() {
    local webui_password=
    if ! [ ${WEBUI_PASSWORD+set} ]; then
	eval "$(webui_config | grep '^webui_password=')"
	WEBUI_PASSWORD=$webui_password
    fi
    echo "$WEBUI_PASSWORD"
}
## sets username and password (multi-user only!) (cached)
unset WEBUI_USERNAME
webui_set_credentials() {
    if ! [ ${WEBUI_USERNAME+set} ]; then
	WEBUI_USERNAME=$CALLMONITOR_USERNAME
	if user_is_compat; then
	    WEBUI_USERNAME=""
	fi
	WEBUI_PASSWORD=$CALLMONITOR_PASSWORD
	if [ -z "$WEBUI_PASSWORD" ]; then
	    WEBUI_PASSWORD=$(user_getpw "$WEBUI_USERNAME")
	fi
    fi
    username=$WEBUI_USERNAME
    password=$WEBUI_PASSWORD
}

## 2008-08-23: The interface to query.txt has been modified in recent 7270
## (Labor) firmwares. Let's try to use both interfaces simultaneously instead
## of doing some kind of firmware detection.
webui_query() {
    local query="getpage=../html/query.txt&var:cnt=$#" var= n=0
    for var; do
	local value=$(urlencode "$var")
	query="$query&var:n${n}=${value}&var:n%5b${n}%5d=${value}"
	let n++
    done
    webui_get "$query" | sed -e '1,/^$/d;$d'
}

## To be overwritten
self_host() {
    echo fritz.box
}
