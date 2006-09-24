##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
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

require message
require url
require http
require getopt

## Basic networking utilities

## connection; no arguments; needs TIMEOUT, HOST, and PORT
_connect() {
    __nc "$TIMEOUT" "$HOST" "$PORT"
}

__getmsg_usage() {
#<
    cat <<'EOH'
Usage:	getmsg [OPTION]... <authority> <part-url-template> [<message>]...
	getmsg [OPTION]... -t <part-url-template> <authority> [<message>]...
	getmsg [OPTION]... <full-url-template> [<message>]...
Send a message in a simple HTTP GET request.

  -t, --template=FORMAT  use this printf-style template to build the URL,
			 all following messages are URL-encoded and filled
			 into this template
  -T TYPE                type of message (use default_TYPE, encode_TYPE, etc.)
  -p, --port=PORT	 use a special target port (default 80)
  -w, --timeout=SECONDS  set connect timeout (default 3)
  -v, --virtual=VIRT	 use a different virtual host (default HOST)
  -U, --user=USER	 user for basic authorization
  -P, --password=PASS	 password for basic authorization
      --help		 show this help

  <full-url-template>    http://<authority><partial-url-template>
  <part-url-template>    e.g., /path/to/resource?query=string&message=%s
  <authority>            [user[:password]@]host[:port]
EOH
#>
}

# return value: number of consumed arguments
_opt_net() {
    _opt_nc "$@" || return $?
    case $1 in
	-t|--template)
	    TEMPLATE="$2"; return 2 ;;
	-T)
	    TYPE="$2"; return 2 ;;
    esac
    return 0
}
_opt_nc() {
    case $1 in
	-w|--timeout)
	    TIMEOUT="$2"; return 2 ;;
	-p|--port)
	    PORT="$2"; return 2 ;;
    esac
    return 0
}
readonly var_nc="TIMEOUT PORT"
readonly var_net="$var_nc TEMPLATE TYPE"

_getopt_getmsg() {
    getopt -n getmsg -o T:U:P:v:t:w:p: \
	-l user:,password:,virtual:,port:,template:,timeout:,help -- "$@"
}
_opt_auth() {
    case $1 in
	-U|--user)
	    USERNAME="$2"; return 2 ;;
	-P|--password)
	    PASSWORD="$2"; return 2 ;;
    esac
    return 0
}
readonly var_auth="USERNAME PASSWORD"
_opt_getmsg() {
    _opt_net "$@" || return $?
    _opt_auth "$@" || return $?
    case $1 in
	-v|--virtual)
	    HTTP_VIRTUAL="$2"; return 2 ;;
	--help)
	    __getmsg_usage >&2; ERROR=1 ;;
    esac
    return 0
}
readonly var_getmsg="$var_net $var_auth HTTP_VIRTUAL"

__getmsg() {
    local $VAR_http; unset $VAR_http
    local - $var_getmsg HOST=; unset $var_getmsg
    local TYPE=message PORT=80 TIMEOUT=3
    local SEND="__getmsg_$1"; shift
    _getopt getmsg "$@"
}
_body_getmsg() {
    if ? $# == 0; then echo "Missing hostname or IP" >&2; return 1; fi
    __getmsg_parse "$1" || return 1; shift
    if empty "$TEMPLATE"; then
	if ? $# == 0; then echo "Missing template" >&2; return 1; fi
	TEMPLATE="$1"; shift
    fi
    if ? $# == 0; then set -- "$(default_$TYPE)"; fi
    _http_prepare
    $SEND "$@"
}

getmsg() {
    __getmsg simple "$@"
}
__getmsg_simple() {
    HTTP_PATH="$(
	n=1
	for arg in "$@"; do
	    shift; set -- "$@" "$(__getmsg_encode "$arg" $n)"
	    let n++
	done
	printf "$TEMPLATE" "$@"
    )"
    {
	_http_init_request GET
	_http_end_header
    } | _connect
}
__getmsg_encode() {
    if type encode_$TYPE >/dev/null; then
	urlencode "$(encode_$TYPE "$1" "$2")"
    else
	urlencode "$1"
    fi
}

## parse first argument: HOST | full URL template
__getmsg_parse() {
    if url_parse "$1"; then
	case $url_scheme in
	    http)
		TEMPLATE="${url_path:-/}${url_query:+?$url_query}"
		__msg_set_authority
		return 0
	    ;;
	esac
    fi
    if url_parse_authority "$1"; then
	__msg_set_authority
	return 0
    fi
    echo "Did not recognize URL or authority '$1'" >&2
    return 1
}

## set message variables from URL parsing result (authority only)
__msg_set_authority() {
    if ! empty "$url_user"; then
	USERNAME=$(urldecode "$url_user")
    fi
    if ! empty "$url_auth"; then
	PASSWORD=$(urldecode "$url_auth")
    fi
    HOST=$url_host
    if ! empty "$url_port"; then
	PORT=$(urldecode "$url_port")
    fi
}

## 'raw' TCP message

__rawmsg_usage() {
#<
    cat <<'EOH'
Usage: rawmsg [OPTION]... <host[:port]> <template> [<param>]...
       rawmsg [OPTION]... -t <template> <host[:port]> [<param>]...
Send a message over a plain TCP connection.

  -t, --template=FORMAT  use this printf-style template to build the message,
			 all following parameters are filled in
  -T TYPE                type of message (use default_TYPE, etc.)
  -p, --port=PORT	 use a special target port (default 80)
  -w, --timeout=SECONDS  set connect timeout (default 3)
      --help		 show this help
EOH
#>
}

_getopt_rawmsg() {
    getopt -n rawmsg -o T:t:w:p: -l port:,template:,timeout:,help -- "$@"
}
_opt_rawmsg() {
    _opt_net "$@" || return $?
    case $1 in
	--help)
	    __rawmsg_usage >&2; ERROR=1 ;;
    esac
    return 0
}
readonly var_rawmsg="$var_net"

__rawmsg() {
    local - HOST= $var_rawmsg; unset $var_rawmsg
    local PORT=80 TIMEOUT=3 TYPE=raw
    local SEND="__rawmsg_$1"; shift
    _getopt rawmsg "$@"
}
_body_rawmsg() {
    if ? $# == 0; then echo "Missing hostname or IP" >&2; return 1; fi
    if url_parse_authority "$1"; then
	shift
	__msg_set_authority
    else
	return 1
    fi
    if empty "$TEMPLATE"; then
	if ? $# == 0; then echo "Missing template" >&2; return 1; fi
	TEMPLATE="$1"; shift
    fi
    if ? $# == 0; then set -- "$(default_$TYPE)"; fi
    $SEND "$@"
}

rawmsg() {
    __rawmsg simple "$@"
}
__rawmsg_simple() {
    printf "$TEMPLATE" "$@" | _connect
}
default_raw() {
    default_message
}

## post form data (application/x-www-form-urlencoded) via HTTP

post_form() {
    local url=$1 data=$2 TIMEOUT= HOST= PORT=80
    local $VAR_http; unset $VAR_http
    local $VAR_url
    if url_parse "$url"; then
	case $url_scheme in
	    http)
		## good
		;;
	    *) echo "Only HTTP is supported" >&2; return 1 ;;
	esac
    else
	echo "Could not parse URL '$url'" >&2
	return 1
    fi
    __msg_set_authority
    _http_prepare
    local HTTP_PATH="${url_path:-/}${url_query:+?$url_query}"
    local content_type=application/x-www-form-urlencoded
    {
	_http_init_request POST
	echo "Content-Type: $content_type$CR"
	echo "Content-Length: ${#data}$CR"
	_http_end_header
	echo -n "$data" 
    } | _connect
}
