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

## carriage return & line feed
readonly CR=""
readonly LF="
"

## output an HTTP Authorization header (Basic)
## _http_basic_auth <user> <password>
_http_basic_auth() {
    local user="$1" password="$2"
    echo -n "$user:$password" | uuencode -m - |
    sed -e '1d;2s/^/Authorization: Basic /;3,$s/^/ /;s/$/'$CR'/;$d'
}

## HTTP utilities

readonly _VAR_http="HTTP_PATH HTTP_VIRTUAL HTTP_AUTH"
_http_init_request() {
    local method=$1
    echo "$method $HTTP_PATH HTTP/1.0$CR"
    echo "Host: $HTTP_VIRTUAL$CR"
    ! empty "$HTTP_AUTH" && echo "$HTTP_AUTH"
}
_http_end_header() {
    echo "$CR"
}

## prepare some HTTP headers
_http_prepare() {
    if ! empty "$USERNAME$PASSWORD"; then
	HTTP_AUTH="$(_http_basic_auth "$USERNAME" "$PASSWORD")"
    fi
    HTTP_VIRTUAL="${HTTP_VIRTUAL:-$HOST}"
}
