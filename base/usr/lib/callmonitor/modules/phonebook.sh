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
require net

## resolve numbers to names and addresses (www.dasoertliche.de); the number is
## used as given (should be normalized beforehand); returns 1 if no lookup
## performed (no need to cache)
reverse_lookup() {
    local NUMBER="$1"
    case "$NUMBER" in
	00*|[^0]*|*[^0-9]*) return 1;
    esac
    getmsg -w 5 www.dasoertliche.de "$NUMBER" \
    -t '/DB4Web/es/oetb2suche/home.htm?main=Antwort&s=2&SKN=2&kw_invers=%s' |
    sed -e '
	/^[[:space:]]*<td[^>]*><a[[:space:]]\+class="\(blb\|bigblunderrd\)".*<\/td>[[:space:]]*$/!d
	\#<br># s#[[:space:]]*$#)#
	s#<br># (#
	s#<br>#, #g
	s#<[^>]*># #g
	s#[[:space:]]\+# #g
	s#^ ##
	s# \([,)]\)#\1#g
	s#\([(]\) #\1#g
	s# $##
	q # first entry only
    '
}

normalize_address() {
    local NUMBER="$1"
    case "$NUMBER" in
	SIP*) normalize_sip "$NUMBER" ;;
	*)    normalize_tel "$NUMBER" ;;
    esac
}

## normalize phone numbers
normalize_tel() {
    local NUMBER="$1"
    case $NUMBER in
	0049*) NUMBER="0${NUMBER#0049}" ;;
	49*) if ? "${#NUMBER} > 10"; then NUMBER="0${NUMBER#49}"; fi ;;
    esac
    case $NUMBER in
	[1-9]*) NUMBER="${CALLMONITOR_OKZ}${NUMBER}" ;; 
    esac
    echo "$NUMBER"
}

## transform SIP[0-9] into SIP addresses
normalize_sip() {
    local NUMBER="$1"
    case "$NUMBER" in
	SIP[0-9])
	    if eval "[ \"\${${NUMBER}_address+set}\" ]"; then
		eval "NUMBER=\"\$${NUMBER}_address\""
	    fi
	    ;;
    esac
    echo "$NUMBER"
}
## read SIP[0-9] to address mapping
if < /var/run/phonebook/sip; then
    . /var/run/phonebook/sip
fi
