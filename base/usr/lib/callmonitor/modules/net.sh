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

## Basic networking utilities

## carriage return & line feed
CR=""
LF="
"

## output an HTTP Authorization header (Basic)
## basic_auth <user> <password>
basic_auth() {
    local user="$1" password="$2"
    echo -n "$user:$password" | uuencode -m - |
    sed -e '1d;2s/^/Authorization: Basic /;3,$s/^/ /;s/$/'$CR'/;$d'
}

## convert latin1 to utf8
latin1_utf8() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e '
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
    ' |
    while IFS= read -r line; do echo -ne "$line"; done
}

## convert latin1 to utf8
utf8_latin1() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e '
	s/ c2 \([89ab]\)/\1/g
	s/ c3 8/c/g
	s/ c3 9/d/g
	s/ c3 a/e/g
	s/ c3 b/f/g
	: multi
	s/ [cd]. ../3f/g
	s/ e. .. ../3f/g
	s/ f\([0-7].\|[89ab]. ..\|[cd]. .. ..\) .. .. ../3f/g
	/ [c-f]/ {
	    N
	    s/\n//
	    b multi
	}
	s/ //g
	s/\(..\)/\\x\1/g
    ' |
    while IFS= read -r line; do echo -ne "$line"; done
}

## option parsing
_getopt() {
    local - TEMP ERROR=0 name=$1
    shift
    TEMP="$(_getopt_$name "$@")" || return 1
    set -f; eval "set -- $TEMP"; set +f
    while true; do
	_opt_$name "$@"; consumed=$?
	if ? "ERROR > 0"; then
	    return $ERROR
	fi
	if ? "consumed > 0"; then
	    shift $consumed
	else
	    case $1 in
		--) shift; break ;;
		*) echo "$name: unrecognized option \`$1'"; return 1 ;;
	    esac
	fi
    done
    _body_$name "$@"
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
getmsg() {
    __getmsg __getmsg_simple "$@"
}

# return value: number of consumed arguments
_opt_net() {
    case $1 in
	-t|--template)
	    TEMPLATE="$2"; return 2 ;;
	-w|--timeout)
	    TIMEOUT="$2"; return 2 ;;
	-p|--port)
	    PORT="$2"; return 2 ;;
	-T)
	    TYPE="$2"; return 2 ;;
    esac
    return 0
}

_getopt_getmsg() {
    getopt -n getmsg -o T:U:P:v:t:w:p: \
	-l user:,password:,virtual:,port:,template:,timeout:,help -- "$@"
}
_opt_getmsg() {
    _opt_net "$@" || return $?
    case $1 in
	-U|--user)
	    USERNAME="$2"; return 2 ;;
	-P|--password)
	    PASSWORD="$2"; return 2 ;;
	-v|--virtual)
	    VIRTUAL="$2"; return 2 ;;
	--help)
	    __getmsg_usage >&2; ERROR=1 ;;
    esac
    return 0
}

__getmsg() {
    local - HOST= URL= TEMPLATE= VIRTUAL= USERNAME= PASSWORD= AUTH= SEND=
    local TYPE=message PORT=80 TIMEOUT=3 consumed
    SEND="$1"; shift
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
    VIRTUAL="${VIRTUAL:-$HOST}"
    if ! empty "$USERNAME$PASSWORD"; then
	AUTH="$(basic_auth "$USERNAME" "$PASSWORD")"
    fi
    $SEND "$@"
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
__getmsg_simple() {
    URL="$(
	n=1
	for arg in "$@"; do
	    shift; set -- "$@" "$(__getmsg_encode "$arg" $n)"
	    let n++
	done
	printf "$TEMPLATE" "$@"
    )"
    {
	echo "GET $URL HTTP/1.0$CR"
	echo "Host: $VIRTUAL$CR"
	! empty "$AUTH" && echo "$AUTH"
	echo "$CR"
    } | __nc "$TIMEOUT" "$HOST" "$PORT"
}
__getmsg_encode() {
    if type encode_$TYPE >/dev/null; then
	urlencode "$(encode_$TYPE "$1" "$2")"
    else
	urlencode "$1"
    fi
}

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

rawmsg() {
    local - HOST= TEMPLATE= PORT=80 TIMEOUT=3 TYPE=raw consumed
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
    printf "$TEMPLATE" "$@" | __nc "$TIMEOUT" "$HOST" "$PORT"
}
default_raw() {
    default_message
}

## no authentication support yet
post_form() {
    local url=$1 data=$2 
    local url_scheme url_path url_query url_fragment
    local url_user url_auth url_host url_port
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
    local path="${url_path:-/}${url_query:+?$url_query}"
    local content_type=application/x-www-form-urlencoded
    echo "POST $path HTTP/1.0$CR
Host: $url_host$CR
Content-Type: $content_type$CR
Content-Length: ${#data}$CR
$CR
$data" | nc "$url_host" "${url_port:-80}"
}
