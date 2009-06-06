##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2008  Andreas Bühmann <buehmann@users.berlios.de>
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
##  EVENT	event {in,out}:{request,cancel,connect,disconnect}
##  SOURCE	source number
##  SOURCE_NAME source name
##  DEST	destination number
##  DEST_NAME	destination name
##  ... and others (see $var_cm in callmonitor.sh)

require net
require message
require recode

## get matching IPs from multid.leases and execute a command for each of them
## example: for_leases 192.168.10. dboxpopup "Ring!"
for_leases() {
    local pattern=$1 command=$2 lease mac ip rest
    shift 2
    while read -r lease mac ip rest; do
	case $ip in *$pattern*) "$command" "$ip" "$@" & ;; esac
    done < /var/flash/multid.leases
}

## simple *box listeners
dboxpopup() {
    getmsg -T dboxpopup -t "/control/message?popup=%s" -m 1 "$@"
}
dboxmessage() {
    getmsg -T dboxmessage -t "/control/message?nmsg=%s" -m 1 "$@"
}
default_dboxpopup() { default_dbox; }
default_dboxmessage() { default_dbox; }
default_dbox() {
    default_message
}
## 2009-06-06: D-Box appears to have problems processing some characters [;&]
encode_dboxpopup() { encode_dbox "$@"; }
encode_dboxmessage() { encode_dbox "$@"; }
encode_dbox() {
    echo "$1" | sed -e 's/;/./g;s/&/+/g' | latin1_utf8 | sed -e 's/,[[:space:]]\+/\n/g' 
}

dreammessage() {
    getmsg -T dreammessage \
	-t "/cgi-bin/xmessage?timeout=${DREAM_TIMEOUT:-10}&caption=$(urlprintfencode "${DREAM_CAPTION:-$(lang
    de:"Telefonanruf" en:"Phone call")}")&charset=latin1&icon=${DREAM_ICON:-1}&body=%s" -m 1 "$@"
}
## with Enigma 2
dream2message() {
    getmsg -T dream2message \
	-t "/web/message?timeout=${DREAM_TIMEOUT:-10}&type=${DREAM_ICON:-1}&text=%s" -m 1 "$@"
}
encode_dream2message() {
    echo "$1" | latin1_utf8
}
default_dreammessage() { default_dream; }
default_dream2message() { default_dream; }
default_dream() { default_message; }

## Usage: yac [OPTION]... [MESSAGE]
## Send a message to a yac listener (Yet Another Caller ID Program)
yac() {
    rawmsg -T yac -p 10629 -t "%s\0" "$@"
}
default_yac() {
    echo "@CALL$SOURCE_ENTRY~$SOURCE_DISP"
}

## "Advanced YAC" (for Gundalf's CallMonitor Client)
ayac() {
    rawmsg -T ayac -p 10629 -t "%s\0" "$@"
}
default_ayac() {
    echo "@CALL${SOURCE_ENTRY}~${SOURCE_DISP}~${DEST_ENTRY}~${DEST_DISP}~${TIMESTAMP}~${EVENT}"
}

## Usage: vdr [OPTION]... [MESSAGE]
## Send a message to a VDR (Video Disk Recorder, http://www.cadsoft.de/vdr/)
vdr() {
    rawmsg -T vdr -p 2001 -t "MESG %s\nQUIT\n" "$@"
}
default_vdr() { default_short_message; }

xboxmessage() {
    getmsg -T xboxmessage \
	-t "/xbmcCmds/xbmcHttp?command=ExecBuiltIn&parameter=XBMC.Notification($(urlprintfencode "${XBOX_CAPTION:-$(lang de:"Telefonanruf" en:"Phone call")}"),%s)" -m 1 "$@"
}
default_xboxmessage() {
    default_message "" 2
}
encode_xboxmessage() {
    echo "$1" | tr ",;" "."
}

## DGStation Relook 400S (Geckow Web Interface 1.04)
## (4 lines with about 40 characters (39 according to bolle); "|" is newline;
## Latin-1 and UTF-8 umlauts translate to question marks)
relookmessage() {
    getmsg -T relookmessage \
	-t "/cgi-bin/command?printmessage&${RELOOK_TIMEOUT:-10}%%20%s" -m 1 "$@"
}
default_relookmessage() { default_message 39; }
encode_relookmessage() {
    echo "$1" | sed -n 's,|,/,g;1h;2,4{H;g;s/\n/|/g;h};${g;p}'
}
