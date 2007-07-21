##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2007  Andreas Bühmann <buehmann@users.berlios.de>
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
_reverse_goyellow_request() {
    wget "http://www.goyellow.de/inverssuche/?TEL=$(urlencode "$1")" -q -O -
}
_reverse_goyellow_extract() {
    sed -n -e '
	\#Es wurden keine Eintr.ge gefunden.# {
	    '"$REVERSE_NA"'
	}
	\#<div[^>]*id="listing"#,\#<div[^>]*class="col contact# {
	    /title="Detailinformationen/ b name
	    \#<h3>.*</h3># b name
	    /<p class="address/ b address
	}
	\#<div[^>]*class="col contact# {
	    g
	    s/\n/, /g
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
	b
	: name
	s#^[^<]*<\(a\|h3\)[^>]*>\([^<]*\)</\(a\|h3\)>.*#\2#
	h
	b
	: address
	s#^[^<]*<p[^>]*class="address">\(.*\)</p>#\1#
	s#<br />#, #g
	H
	b
    '
}
