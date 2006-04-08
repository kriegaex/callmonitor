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

## = Einstellungen =
##
## http://www.ip-phone-forum.de/showpost.php?p=525707&postcount=139
##
## [QUOTE=sucram]Hallo Andreas,
##
## kein Problem!
##
## Ich habe die Einstellungen noch einmal 'optimiert'. Mit den folgenden URLs
## lassen sich 4 Zeilen a 17 Zeichen darstellen.
##
## http://192.168.0.10/control/lcd?lock=1&clear=1&xpos=2&ypos=15&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=30&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=45&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=60&size=18&font=2&text=A000000000000000E&update=1
## sleep 10
## http://192.168.0.10/control/lcd?lock=0
##
## sucram[/QUOTE]
##
## = API-Dokumentation =
##
## http://cvs.tuxbox.org/cgi-bin/viewcvs.cgi/tuxbox/apps/tuxbox/neutrino/daemons/nhttpd/api_doku.txt?view=markup

require net

dboxlcd() {
    __getmsg __getmsg_dboxlcd -d default_dboxlcd -t "-" "$@"
}
__getmsg_dboxlcd() {
    local lcd="/control/lcd"
    local lcdtext="$lcd?xpos=1&size=17&font=2&text=%s"
    local line= init="&lock=1&clear=1" ypos=0
    local IFS="$LF"
    echo "$*" |
    for ypos in 12 24 36 48 60; do
	read -r line
	if ! empty "$line"; then
	    TEMPLATE="$lcdtext&ypos=$ypos&update=1$init" __getmsg_simple "$line"
	    init=
	fi
    done
    sleep ${DBOX_TIMEOUT:-10}
    TEMPLATE="$lcd?lock=0" __getmsg_simple
}
default_dboxlcd() {
    local len=${#SOURCE_NAME}
    {
	if ! empty "$DEST_NAME"; then
	    echo "$(lang de:"Anruf an" en:"Call to") $DEST_NAME"
	elif ! empty "$DEST"; then
	    echo "$(lang de:"Anruf an" en:"Call to") $DEST"
	else
	    echo "$(lang de:"Anruf" en:"Call")"
	fi
	if ! empty "$SOURCE"; then
	    echo "$(lang de:"von" en:"from") $SOURCE"
	fi
	if ! empty "$SOURCE_NAME"; then
	    if ? "$len <= 19"; then
		echo "$SOURCE_NAME"
	    else
		expr substr "$SOURCE_NAME" 1 19
		expr substr "$SOURCE_NAME" 20 19
		if ? "$len > 38"; then
		    expr substr "$SOURCE_NAME" 39 19
		fi
	    fi
	fi
    } | latin1_utf8
}
