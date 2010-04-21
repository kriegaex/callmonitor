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
_reverse_telefonbuch_url() {
    local number="0${1#${LKZ_PREFIX}49}"
    URL="http://www.dastelefonbuch.de/?la=de&kw=$(urlencode "$1")&cmd=search"
}
_reverse_telefonbuch_request() {
    local URL=
    _reverse_telefonbuch_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_telefonbuch_extract() {
    sed -n -e '
	/kein Teilnehmer gefunden/ {
	    '"$REVERSE_NA"'
	}
	/<table[^>]*class="[^"]*\(bg-0[12]\|entry\)/,\#<td class="col4"# {
	    \#<div class="[^"]*hide#,\#</div># b
	    \#<td class="col[23]"# s/$/,/
	    H
	    \#<td class="col4"# b cleanup
	}
	b
	: cleanup
	g
	s/'$'\r''\?\n/ /g
	s#<a [^>]*href[^>]*>\(.*\)</a>#<rev:name>&</rev:name>#
	'"$REVERSE_DECODE_ENTITIES"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
