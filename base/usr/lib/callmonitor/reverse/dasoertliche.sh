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
_reverse_dasoertliche_url() {
    local number="0${1#${LKZ_PREFIX}49}"
    URL="http://www.dasoertliche.de/Controller?form_name=search_inv&ph=$(urlencode "$number")"
}
_reverse_dasoertliche_request() {
    local URL=
    _reverse_dasoertliche_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_dasoertliche_extract() {
   sed -n -e '
	: main
        \#Kein Teilnehmer gefunden:\|keine Treffer finden# {
	    '"$REVERSE_NA"'
	}
        \#<div[[:space:]]\+class="adresse"[[:space:]]*>#,\#<input[[:space:]]\+type="hidden"\|<div[[:space:]]class="topx"# {
	    s#^.*<a[[:space:]][^>]*class="preview[^"]*"[^>]*>\([^<]*\)<.*$#\1#
	    t holdname
	    \#<input[[:space:]]\+type="hidden"\|<div[[:space:]]class="topx"# b cleanup
	    H
        }
        b

        : holdname
	s#.*#<rev:name>&</rev:name>#
        h
	b

	: cleanup
	g
	s/\(<br\/>\)\?\n\|<br\/>/, /g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
