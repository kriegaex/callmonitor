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
require net
require message

##     http://www.i-hacked.com/content/view/108/94/
##     http://www.rokulabs.com/community/developer.php
## 
##     Functional Specification Roku Control Protocol
## 	(Port 5555)
##     Shell-Interface
## 	(Port 4444, einfache TCP-Verbindung)

## static text

default_sbmessage() { default_short_message; }
encode_sbmessage() { encode_sb "$@"; }

sbmessage() {
    __rawmsg sbmessage --port=4444 -t dummy "$@"
}
    
__rawmsg_sbmessage() {
    {
	local msg="$(encode_sbmessage "$*")"
	_sb_init
	echo "text c c \"$msg\""
	sleep ${SB_TIMEOUT:-10}
	echo "quit"
    } | _sb_sketch 
}

## scrolling text

default_sbmarquee() { default_message; }
encode_sbmarquee() { encode_sb "$@"; }

sbmarquee() {
    __rawmsg sbmarquee --port=4444 -t dummy "$@"
}
__rawmsg_sbmarquee() {
    {
	local msg="$(encode_sbmessage "$*")"
	local n=${SB_TIMES:-3}
	local timeout=$((1000 * $(_sb_timeout "$msg")))
	local final_timeout=$((1000 * $(SB_OVERLAP=-5 _sb_timeout "$msg")))
	_sb_init
	while ? "n > 0"; do
	    echo "marquee -start \"$msg\""
	    let n--
	    usleep $((n == 0 ? final_timeout : timeout))
	done
	echo "quit"
    } | _sb_sketch
}

## miwu (IPPF):
## Daraus entsteht dann beim Marquee das Problem, dass man den Timeout für
## längere Texte höher setzen muß als für kürzere. Der von Dir erstmal gewählte
## Wert von 5 würde so für ca. 28-30 Zeichen reichen, dann beginnt schon das
## "neue Marquee", während das "neue Marquee" bei einem zu kurzen Timeout das
## vorherige Marquee gnadenlos abschneidet. Ein Timeout-Wert von 7 bedeutet bei
## Deiner Probe-Textlänge [23], dass der neue Durchlauf genau dann beginnt, wenn der
## alte gerade das Display verlassen hat. Jeder Buchstabe wird also ca. 5
## Sekunden lang durchlaufend auf dem Display dargestellt.

## Schön finde ich, dass es bei Marquee funktioniert, den Textanfang des 2.
## Marquee von rechts reinlaufen zu lassen, während das Ende des 1. Marquees
## noch rausläuft. Das Display muß also nicht zwischen den Marquees gecleart
## werden (machst Du ja auch nur vor dem 1.).

## Fehlt nur noch die Anzahlt der darstellbaren Zeichen. In der Schriftart
## Nummer 2 (Vertiakal displayfüllend) werden mit bei folgendem Befehl 35
## Zeichen dargestellt.
## 
## sketch -c text c c 0123456789012345678901234567890123456789
## 
## zeigt also
## 
## 01234567890123456789012345678901234
## 
## an.

_sb_timeout() {
    local msg="$1"
    local len=${#msg}

    ## about how many chars fit into the display
    local visible=${SB_VISIBLE:-35}

    ## start a new run when so many chars are left
    local overlap=${SB_OVERLAP:-10}

    ## how fast are the characters moving
    local speed=${SB_SPEED:-7500} ## milli-chars per second :o)
    local time
    let "time = (len + visible - overlap) * 1000000 / speed" ## milliseconds
    echo $((time < 0 ? 0 : time))
}

## common definitions

## We do not use 'echo "$1"' because we need a single-line message (whitespace
## is collapsed, which could be undesired)
encode_sb() {
    case $1 in
	*[\"\\]*) echo $1 | sed -e 's/["\]/\\&/g' ;;
	*) echo $1 ;;
    esac
}

## helpers

_sb_sketch() {
    {
	echo "sketch"
	cat
    } | _connect
}
_sb_init() {
    echo "font ${SB_FONT:-2}"
    echo "encoding latin1"
    echo "clear"
}
