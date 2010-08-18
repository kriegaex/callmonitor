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
_reverse_goyellow_url() {
    local number="0${1#${LKZ_PREFIX}49}"
    URL="http://www.goyellow.de/inverssuche/?TEL=$(urlencode "$number")"
}
_reverse_goyellow_request() {
    local URL=
    _reverse_goyellow_url "$@" 
    wget_callmonitor "$URL" -q -O -
}
_reverse_goyellow_extract() {
    local b=$'\1' e=$'\2'
    local c="[^$b$e]"
    sed -n -e '
	\#haben wir nichts gefunden# {
	    '"$REVERSE_NA"'
	}
	\#<div id="searchResultListing"#,\#<p class="moreInfo"# {
	    \#<span class="normal fn# b name
	    \#<span class="\(comma\|postcode\|city \)# H
	    \#<span class="street encAdr"># b street
	    \#<span class="street # H
	}
	\#<p class="moreInfo"# {
	    g
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
	b
	: name
	s#.*#<rev:name>&</rev:name>#
	h
	b
	: street
	s#.*<span[^>]*>#'"$b$b$b"'#
	s#</span>.*#'"$e"'#
	H
	b
    ' | utf8_latin1 | sed -r "
    	: loop
	s/$b($c*)$b($c*)$b($c)($c)?/$b\1\3$b\4\2$b/
	t loop
	s/[$b$e]//g
    "
}
