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
_reverse_anywho_url() {
    local number="${1#${LKZ_PREFIX}1}"
    URL="http://www.anywho.com/qry/wp_rl?telephone=$(urlencode "$number")"
}
_reverse_anywho_request() {
    local URL=
    _reverse_anywho_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_anywho_extract() {
   sed -n -e '
	: main
        \#Unable to return results\|<!-- /All_LISTINGS # {
	    '"$REVERSE_NA"'
	}
	/<!-- listing /,\#<!-- /listing\|<DIV CLASS="phone"# {
	    /<!-- Out for now /d
	    H
	}
	\#<!-- /listing \|<DIV CLASS="phone"# b cleanup
	b

	: cleanup
	g
	s#<B>#<rev:name>#
	s#</B>#</rev:name>#
	s/<BR>/, /g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
