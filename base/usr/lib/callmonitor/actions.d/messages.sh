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

## Listener types and common utilities; separate function for each type
## of listener. Put your own into $CALLMONITOR_LIBDIR/actions.local.d/*.sh
## 
## These environment variables are set by callmonitor before calling
## calling a listener:
##  SOURCE	source number
##  SOURCE_NAME source name
##  DEST	destination number
##  DEST_NAME	destination name

require net

## get matching IPs from multid.leases and execute a command for each of them
## example: for_leases 192.168.10. dboxpopup "Ring!"
for_leases() {
    local IPS="$(fgrep -i "$1" /var/flash/multid.leases | awk '{ print $3 }')"
    local COMMAND="$2" IP=
    shift 2
    for IP in $IPS; do
	"$COMMAND" "$IP" "$@" &
    done
}

## simple *box listeners
dboxpopup() {
    getmsg -t "/control/message?popup=%s" -d default_dboxpopup "$@"
}
dboxmessage() {
    getmsg -t "/control/message?nmsg=%s" -d default_dboxmessage "$@"
}
default_dboxpopup() { default_dbox; }
default_dboxmessage() { default_dbox; }
default_dbox() {
    default_message | latin1_utf8 | sed -e 's/,[[:space:]]\+/\n/g'
}
dreammessage() {
    getmsg -t "/cgi-bin/xmessage?timeout=${DREAM_TIMEOUT:-10}&caption=${DREAM_CAPTION:-Telefonanruf}&charset=latin1&icon=${DREAM_ICON:-1}&body=%s" -d default_dreammessage "$@"
}
default_dreammessage() { default_message; }

## Usage: yac [OPTION]... [MESSAGE]
## Send a message to a yac listener (Yet Another Caller ID Program)
yac() {
    rawmsg -p 10629 -t "%s\0" -d default_yac "$@"
}
default_yac() {
    echo "@CALL$SOURCE_NAME~$SOURCE"
}

## Usage: vdr [OPTION]... [MESSAGE]
## Send a message to a VDR (Video Disk Recorder, http://www.cadsoft.de/vdr/)
vdr() {
    rawmsg -p 2001 -t "MESG %s\nQUIT\n" -d default_vdr "$@"
}
default_vdr() {
    echo "Anruf${SOURCE:+" $SOURCE"}${SOURCE_NAME:+" - $SOURCE_NAME"}"
}

xboxmessage() {
    getmsg -t "/xbmcCmds/xbmcHttp?command=ExecBuiltIn&parameter=XBMC.Notification(${XBOX_CAPTION:-Telefonanruf},%s)" -d default_xboxmessage "$@"
}
__xboxmessage() {
    default_xboxmessage | tr "," ";"
}
default_xboxmessage() {
    if ! empty "$DEST_NAME"; then
	echo "Anruf an $DEST_NAME"
    elif ! empty "$DEST"; then
	echo "Anruf an $DEST"
    else
	echo "Anruf"
    fi
    if ! empty "$SOURCE_NAME"; then
	echo "von $SOURCE_NAME"
    elif ! empty "$SOURCE"; then
	echo "von $SOURCE"
    fi
}
