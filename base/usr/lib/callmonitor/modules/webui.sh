##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2011  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##
require url

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
	*)
	    return 2
	;;
    esac
}

WEBUI_LIFETIME=120

## Login (and obtain a session id)
webui_login() {
    local now=$(date +%s) expires=${WEBUI_EXPIRES:-0}
    [ "$now" -lt "$expires" ] && return
    
    webui_login_do

    let WEBUI_EXPIRES="now + WEBUI_LIFETIME"
}
webui_login_do() {
    local password=$(webui_password) sinfo
    sinfo=$(webui_login_sid)
    if [ $? -ne 0 ]; then
	## old login
	unset WEBUI_SID
	if ! empty "$password"; then
	    webui_post_form "login:command/password=$(urlencode "$password")" \
	    > /dev/null
	fi
    else
	## new login
	local iswriteaccess SID Challenge
	eval "$sinfo"
	if [ ${iswriteaccess:-0} -eq 0 ]; then

    	    ## we are being challenged
	    local md5="$(echo -n "$Challenge-$password" |
	    	sed -e 's/./&\n/g' | tr '\n' '\0' | md5sum)"
	    md5=${md5%% *}
	    local response="$Challenge-$md5"

    	    ## respond and (hopefully) receive a SID
	    unset iswriteaccess SID Challenge
	    sinfo=$(webui_login_sid "login:command/response=$response") &&
		eval "$sinfo"
	fi
	WEBUI_SID=$SID
    fi
}

## Terminate the current session
webui_logout() {
    if ! empty "$WEBUI_SID"; then
	webui_post_form "security:command/logout=" > /dev/null
	unset WEBUI_SID
    fi
    unset WEBUI_EXPIRES
}

webui_post_form() (
    cd "$WEBCM_DIR"
    local post_data="${WEBUI_SID:+sid=$WEBUI_SID&}$1" REMOTE_ADDR=127.0.0.1
    webui_post_form_generic "$WEBCM" "$post_data"
)
webui_get() (
    cd "$WEBCM_DIR"
    REQUEST_METHOD=GET REMOTE_ADDR=127.0.0.1 \
    WEBDIR_PATH=/usr/www/html \
    QUERY_STRING="${WEBUI_SID:+sid=$WEBUI_SID&}$1" "$WEBCM"
)

## requires /usr/bin/cfg2sh
webui_config() {
    cfg2sh ar7 webui
}

## cache password
unset WEBUI_PASSWORD
webui_password() {
    local webui_password=
    if ! [ ${WEBUI_PASSWORD+set} ]; then
	eval "$(webui_config | grep '^webui_password=')"
	WEBUI_PASSWORD=$webui_password
    fi
    echo "$WEBUI_PASSWORD"
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

# To be overwritten
self_host() {
    echo fritz.box
}

webui_page_url() {
    local menu=${1%/*} pagename=${1#*/}
    echo "http://$(self_host)/cgi-bin/webcm?getpage=..%2Fhtml%2F${Language:-de}%2Fmenus%2Fmenu2.html&var%3Alang=${Language:-de}&var%3Apagename=$(urlencode "$pagename")&var%3Amenu=$(urlencode "$menu")"
}
