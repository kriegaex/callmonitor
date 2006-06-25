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

## resolve numbers to names and addresses; the number is
## used as given (should be normalized beforehand); returns 1 if no lookup
## performed or if there were errors (no need to cache)
##
## The resulting name and address should be returned in Latin-1 encoding

reverse_lookup() {
    local NUMBER="$1"
    case "$NUMBER" in
	00*|[^0]*|*[^0-9]*) return 1;
    esac
    local prov
    case $CALLMONITOR_REVERSE_PROVIDER in
	weristdran|inverssuche|dasoertliche) prov=$CALLMONITOR_REVERSE_PROVIDER ;;
	*) prov=dasoertliche ;;
    esac
    _reverse_lookup $prov "$NUMBER"
}

_reverse_lookup() {
    local prov=$1 number=$2 exit=0
    eval $({
	{ _reverse_${prov}_request "$number"; echo exit=$? >&4; } |
	_reverse_${prov}_extract
    } 4>&1 >&9)
## 141: nc: Broken pipe
    return $(( exit == 141 ? 0 : exit ))
} 9>&1

_reverse_dasoertliche_request() {
    getmsg -w 5 www.dasoertliche.de "$1" \
	-t '/DB4Web/es/oetb2suche/home.htm?main=Antwort&s=2&SKN=2&kw_invers=%s'
}
_reverse_dasoertliche_extract() {
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

_reverse_weristdran_request() {
    local data="telnr=$1"
    post_form "http://wer-ist-dran.de/index.php?g=a" "$data"
}
_reverse_weristdran_extract() {
    sed -n -e '
	\#Kein Eintrag gefunden#q
	\#<td class="a"#,\#</td>#{
	    /Tel\./{
		s/,\?[[:space:]]*Tel.[[:digit:][:space:]]*<.*$//
		s/^[[:space:]]*//
		p
		q
	    }
	}
    '
}

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
	    \#</div>[[:space:]]*</div>[[:space:]]*$#!b again
	    s/&nbsp;/ /g
	    s/[[:space:]]*<div[^>]*>[[:space:]]*/, /g
	    s/[[:space:]]*<[^>]*>[[:space:]]*/ /g
	    s/[[:space:]]*,\([[:space:]]*,\)*[[:space:]]*/, /g
	    s/^[[:space:]]*,[[:space:]]*//
	    s/[[:space:]]*,[[:space:]]*$//
	    p
	    q
	}
    ' | utf8_latin1
}
