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

## convert latin1 to utf8
latin1_utf8() {
    _recode '
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
    '
}
## convert latin1 to JSON string (utf8) without enclosing double quotes
latin1_json() {
    _recode '
	s/ 08/5c62/g
	s/ 0c/5c66/g
	s/ 0a/5c6e/g
	s/ 0d/5c72/g
	s/ 09/5c74/g
	s/ \([01]\)\([0-9]\)/5c7530303\13\2/g
	s/ \([01]\)a/5c7530303\161/g
	s/ \([01]\)b/5c7530303\162/g
	s/ \([01]\)c/5c7530303\163/g
	s/ \([01]\)d/5c7530303\164/g
	s/ \([01]\)e/5c7530303\165/g
	s/ \([01]\)f/5c7530303\166/g
	s/ \(22\|5c\)/5c\1/g
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
    '
}

## convert utf8 to latin1
utf8_latin1() {
    _recode '
	s/ c2 \([89ab]\)/\1/g
	s/ c3 8/c/g
	s/ c3 9/d/g
	s/ c3 a/e/g
	s/ c3 b/f/g
	: multi
	s/ [cd]. ../3f/g
	s/ e. .. ../3f/g
	s/ f\([0-7].\|[89ab]. ..\|[cd]. .. ..\) .. .. ../3f/g
	/ [c-f]/ {
	    N
	    s/\n//
	    b multi
	}
	s/ //g
	s/\(..\)/\\x\1/g
    '
}

_recode() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e "$1" |
    while IFS= read -r line; do echo -ne "$line"; done
}
