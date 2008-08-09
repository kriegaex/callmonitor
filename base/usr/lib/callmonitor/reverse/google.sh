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
_reverse_google_url() {
    ## anonymize as far as possible (use only the first nine digits)
    local number=$(expr substr "$1" 1 9)0000000000
    URL="http://www.google.de/search?num=1&q=$(urlencode "$number")"
}
_reverse_google_request() {
    local URL=
    _reverse_google_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_google_extract() {
    sed -n -e '
	/Call-by-Call-Vorwahlen/{
	    s#.*/images/euro_phone.gif[^>]*>\([[:space:]]*<[^>]*>\)*[[:space:]]*##
	    s#[[:space:]]*<.*##
	    s#^Deutschland,[[:space:]]*##
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
	/Es wurden keine mit Ihrer Suchanfrage/ {
	    '"$REVERSE_NA"'
	}
    '
}
