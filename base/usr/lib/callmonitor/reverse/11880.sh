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
_reverse_11880_url() {
    local number="0${1#${LKZ_PREFIX}49}"
    URL="http://www.11880.com/inverssuche/index/search?method=searchSimple&_dvform_posted=1&phoneNumber=$(urlencode "$number")"
}
_reverse_11880_request() {
    local URL=
    _reverse_11880_url "$@"
    wget_callmonitor "$URL" -q -O - 
}
_reverse_11880_extract() {
    sed -n -e '
	/class="noResultCities"\|keinen Teilnehmer ermitteln/ {
	    '"$REVERSE_NA"'
	}
	/<[^[:space:]>]*[[:space:]]class="head[[:space:]]/,/<[^[:space:]>]*[[:space:]]class="numericdata/ {
	    /<[^[:space:]>]*[[:space:]]class="numericdata/ b found
	    /<a href=[^>]*#ratingform/ d
	    H
	}
	b
	: found
	g
	s#<a class="namelink"[^>]>#<rev:name>#
	s#</a>#</rev:name>#
	s#<br />#, #g
	'"$REVERSE_DECODE_ENTITIES"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
