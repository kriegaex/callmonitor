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
_reverse_local_ch_url() {
    local number="0${1#${LKZ_PREFIX}41}"
    URL="http://mobile.tel.local.ch/de/q/?what=$(urlencode "$number")"
}
_reverse_local_ch_request() {
    local URL=
    _reverse_local_ch_url "$@"
    wget_callmonitor "$URL" -q -O -
}

_reverse_local_ch_extract() {
    sed -n -e '
	\#keine Eintr..\?ge gefunden# {
	    '"$REVERSE_NA"'
	}
	\#<div class="[^"]*\(bus\|res\)result# {
	    s#<div class="adr">\(\([^<]\|<\([^/]\|/\([^d]\|d[^i]\|di[^v]\)\)\)*\)</div>.*$# \1#
	    s#<p class="phoneNumber">\([^<]\|<[^/]\|</[^p]\|</p[^ >]\)*</p>##
	    s#^.*<div class="[^"]*\(bus\|res\)result"[^>]*>##
	    s#</\?a\(>\| [^>]*>\)##g
	    s#<h2 class="fn">\([^<]*\)</h2>#<rev:name>\1</rev:name>#
	    s#<br/>#,#g
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
    ' | utf8_latin1
}
