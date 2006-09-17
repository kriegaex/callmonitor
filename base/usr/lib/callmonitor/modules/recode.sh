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

## convert latin1 to utf8
latin1_utf8() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e '
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
    ' |
    while IFS= read -r line; do echo -ne "$line"; done
}

## convert utf8 to latin1
utf8_latin1() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e '
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
    ' |
    while IFS= read -r line; do echo -ne "$line"; done
}
