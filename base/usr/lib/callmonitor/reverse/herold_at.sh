##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2010  Andreas Bühmann <buehmann@users.berlios.de>
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
_reverse_herold_at_url() {
    local number="0${1#${LKZ_PREFIX}43}"
    URL="http://www.herold.mobi/-/findlisting?what=$(urlencode "$number")&searchtype=WHITEPAGES"
}
_reverse_herold_at_request() {
    local URL=
    _reverse_herold_at_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_herold_at_extract() {
    sed -n -e '
	/Keine Ergebnisse/ {
	    '"$REVERSE_NA"'
	}
	# very fragile
	/^<div class="result"/,\#^</div># {
	    /<div class="highlight/,\#<br/>$# {
	    	\#<br/>$# b cleanup
	    	H
	    }
	}
	b
	
	: cleanup
	g
	s#.*<b>\([^<]*\)</b>#<rev:name>\1</rev:name>#
	s#<br/>#, #g
	'"$REVERSE_DECODE_ENTITIES_UTF8"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    ' | utf8_latin1
}
