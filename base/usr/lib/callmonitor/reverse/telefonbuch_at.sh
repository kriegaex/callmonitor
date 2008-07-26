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
_reverse_telefonbuch_at_request() {
    local number="0${1#${LKZ_PREFIX}43}"
    wget_callmonitor -q -O - "http://www.tb-online.at/index.php?pc=in&aktion=suchein&telnummer=$(urlencode "$1")"
}
_reverse_telefonbuch_at_extract() {
    sed -n -e '
	/keine passenden Teilnehmer gefunden/ {
	    '"$REVERSE_NA"'
	}
	/<div class="ergebnis"/,/<div class="servicelinks"/ {
	    /<div class="adresse"/ b adresse
	}
	b
	
	: adresse
	\#</div># b cleanup
	/<div class="servicelinks"/ b cleanup
	s/$/, /g
	H
	n; b adresse
	
	: cleanup
	g
	s/<p class="telnummer".*//
	s#</p>#, #g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
