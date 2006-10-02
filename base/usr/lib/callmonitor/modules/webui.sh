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
require url

WEBCM_DIR="/usr/www/html/cgi-bin"
WEBCM=$WEBCM_DIR/webcm

webui_post_form() (
    cd "$WEBCM_DIR"
    local post_data=$1
    echo -n "$POST_DATA" |
    REQUEST_METHOD="POST" \
    REMOTE_ADDR="127.0.0.1" \
    CONTENT_TYPE="application/x-www-form-urlencoded" \
    CONTENT_LENGTH=${#post_data} \
    $WEBCM
)
webui_get() (
    cd "$WEBCM_DIR"
    REQUEST_METHOD="GET" \
    REMOTE_ADDR="127.0.0.1" \
    QUERY_STRING=$1 \
    $WEBCM
)
webui_login() {
    webui_post_form "login:command/password=$(urlencode "$(webui_password)")" \
    > /dev/null
}

webui_config() {
    allcfgconv -C ar7 -c -o - | 
    sed -ne '/^webui[[:space:]]*{/,/^}/{
	/=/{s/[[:space:]]*=[[:space:]]*/=/;s/^[[:space:]]*//;p}
    }'
}
webui_password() {
    local password=
    eval "$(webui_config | grep '^password=')"
    echo "$password"
}

webui_query() {
    local query="getpage=..%2Fhtml%2Fquery.txt&var:cnt=$#" var= n=0
    for var; do
	query="$query&var%3An$n=$(urlencode "$var")"
	let n++
    done
    webui_get "$query" | sed -e '1,/^$/d;$d'
}
