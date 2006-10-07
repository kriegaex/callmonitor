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

## URL encoding
urlencode() {
    _urlencode '%\1' "$@"
}
## URL encoding + printf encoding ("%" -> "%%")
urlprintfencode() {
    _urlencode '%%\1' "$@"
}

_urlencode() {
    local replacement=$1; shift
    local txt=$*
    ## shortcut if there aren't any unsafe characters
    case $txt in
	*[!0-9A-Z_a-z!*.-]*) ;;
	*) echo -n "$txt"; return ;;
    esac
    echo -e $(echo -n "$txt" |
    hexdump -v -e '/1 "!%02x"' |
    sed '
	s/!\(2[1ade]\|3[0-9]\|4[1-9a-f]\|5[0-9af]\|6[1-9a-f]\|7[0-9a]\)/\\x\1/g
	s/!\([[:xdigit:]]\{2\}\)/'"$replacement"'/g
    ')
}

## URL decoding
urldecode() {
    case $1 in
	*%*) echo -ne $(echo -n "$1" | sed 's/\\/\\\\/g;s/%/\\x/g') ;;
	*) echo -n "$1" ;;
    esac
}

readonly VAR_url="url_scheme url_path url_query url_fragment url_user url_auth url_host url_port"

## simple generic URL parser (no error checking!)
url_parse() {
    local rest hier_part authority_path authority userinfo host_port

    ## output variables
    unset -v url_scheme url_path url_query url_fragment
    case $1 in
	*:*)
	    url_scheme=${1%%:*} rest=${1#*:}
	    case $rest in
		*\#*) url_fragment=${rest#*\#} rest=${rest%%\#*} ;;
	    esac
	    case $rest in
		*\?*) url_query=${rest#*\?} rest=${rest%%\?*} ;;
	    esac
	    hier_part=$rest
	    authority=
	    case $hier_part in
		//*)
		    authority_path=${hier_part#//}
		    authority=${authority_path%%/*}
		    case $authority_path in
			*/*) url_path="/${authority_path#*/}" ;;
			*) url_path= ;;
		    esac
		;;
		*) url_path=$hier_part ;;
	    esac
	    url_parse_authority "$authority" || return 1
	    
##	    echo url_scheme=$url_scheme
##	    echo url_path=$url_path
##	    echo url_query=$url_query
##	    echo url_fragment=$url_fragment
	    return 0
	;;
	*) return 1 ;;
    esac
}
url_parse_authority() {
    local authority=$1 userinfo host_port
    unset -v url_user url_auth url_host url_port
    case $authority in
	*@*) userinfo=${authority%%@*} ;;
    esac
    host_port=${authority#*@}
    case $host_port in
	*:*) url_host=${host_port%%:*} url_port=${host_port#*:} ;;
	*) url_host=${host_port} url_port= ;;
    esac
    case $userinfo in
	"") ;;
	*:*) url_user=${userinfo%%:*} url_auth=${userinfo#*:} ;;
	*) url_user=${userinfo%%:*} ;;
    esac

##    echo url_user=$url_user
##    echo url_auth=$url_auth
##    echo url_host=$url_host
##    echo url_port=$url_port
    return 0
}
