##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
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
_reverse_inverssuche_request() {
    local data="__EVENTTARGET=cmdSearch&txtNumber=$1"
    post_form http://www.inverssuche.de/teleauskunft/results_inverse.aspx \
	"$data"
}
_reverse_inverssuche_extract() {
    sed -n -e '
	\#<div class="eintrag_name"#{
	    /\([Zz]u viele\|keine\).*gefunden/q
	    : again
	    N
	    s/\n[^\n]*javascript:toggle[^\n]*$//
	    s#<span [^>]*>(Trefferquote.*$##
	    \#</div>[[:space:]]*</div>[[:space:]]*$#!b again
	    s#<div[^>]*>#, #g
	    '"$REVERSE_SANITIZE"'
	    p
	    q
	}
    ' | utf8_latin1
}
