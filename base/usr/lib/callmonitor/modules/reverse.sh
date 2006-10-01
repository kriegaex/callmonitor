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
require recode

## resolve numbers to names and addresses; the number is
## used as given (should be normalized beforehand); returns 1 if no lookup
## performed or if there were errors (no need to cache)
##
## The resulting name and address should be returned in Latin-1 encoding

reverse_lookup() {
    local number=$1 prov area_prov child afile name
    case "$number" in
	00*|[^0]*|*[^0-9]*) return 1;
    esac
    case $CALLMONITOR_REVERSE_PROVIDER in
	inverssuche|dasoertliche|telefonbuch|goyellow)
	    prov=$CALLMONITOR_REVERSE_PROVIDER ;;
	*) prov=telefonbuch ;;
    esac
    case $CALLMONITOR_AREA_PROVIDER in
	google|callmonitor)
	    area_prov=$CALLMONITOR_AREA_PROVIDER ;;
	*) area_prov= ;;
    esac

    afile="/var/run/phonebook/lookup-$area_prov-$number"
    _reverse_lookup "$area_prov" "$number" | _reverse_atomic "$afile" & child=$!
    name=$(_reverse_lookup "$prov" "$number")
    if ! empty "$name"; then
	echo "$name"
    else
	name=$(cat "$afile" 2>/dev/null)
	if ! empty "$name"; then
	    echo "$number ($name)" ## $name is only city
	fi
    fi
    { kill "$child" 2>/dev/null; rm -f "$afile"; } &
}
_reverse_atomic() {
    local file=$1 tmp=$1.tmp
    cat > "$tmp" && mv "$tmp" "$file" || rm "$tmp"
}

_reverse_lookup() {
    local prov=$1 number=$2 exit=0
    case $prov in
	"") return 0 ;;
    esac
    eval $({
	{ _reverse_${prov}_request "$number"; echo exit=$? >&4; } |
	_reverse_${prov}_extract
    } 4>&1 >&9)
## 141: nc: Broken pipe
    return $(( exit == 141 ? 0 : exit ))
} 9>&1

_reverse_dasoertliche_request() {
    wget "http://www.dasoertliche.de/Controller?form_name=search_inv&ph=$(urlencode "$1")" -q -O -
}
_reverse_dasoertliche_extract() {
   sed -n -e '
	: main
        \#Kein Teilnehmer gefunden:#q
        \#<a[[:space:]].*[[:space:]]class="entry">#,\#<input[[:space:]]type="hidden"# {
	    s#^.*<a[[:space:]].*[[:space:]]class="entry">\([^<]*\)</a>.*$#\1#
	    t hold
	    \#<br/># H
	    \#<input[[:space:]]type="hidden"# b cleanup
        }
        b

        : hold
        h
	b

	: cleanup
	g
	s/\(<br\/>\)\?\n\|<br\/>/, /g
	s/<[^>]*>/ /g
	s/\&nbsp;/ /g
	s/[[:space:]]\+/ /g
	s/^ //
	s/ \([,)]\)/\1/g
	s/\([(]\) /\1/g
	s/[[:space:],]*$//
	p
	q
    '
}

_reverse_telefonbuch_request() {
    getmsg -w 5 'http://www.dastelefonbuch.de/?la=de&kw=%s&cmd=search' "$1"
}
_reverse_telefonbuch_extract() {
    sed -n -e '
	/kein Teilnehmer gefunden/q
	/<!-- \*\{2,\} Treffer Eintr.ge \*\{2,\} -->/,/<!-- \*\{2,\} Ende Treffer Eintr.ge \*\{2,\} -->/ {
	    \#^[[:space:]]*$#! H
	}
	/<!-- \*\{2,\} Ende Treffer Eintr.ge \*\{2,\} -->/ {
	    g
	    s#^[^<]*\(<[^a][^<]*\)*<a[^>]*title="\([^"]*\)"[[:space:]]*>.*<td width="180">\([^<]*\)</td>.*<span title="\([^"]*\)".*$#\2, \3, \4#
	    t cleanup
	    q
	}
	b
	: cleanup
	s#,\([[:space:]]*,\)\+#,#
	p
	q
    '
}

_reverse_goyellow_request() {
    wget "http://www.goyellow.de/inverssuche/?TEL=$(urlencode "$1")" -q -O -
}
_reverse_goyellow_extract() {
    sed -n -e '
	\#Es wurden keine Eintr.ge gefunden.# q
	\#<div[^>]*id="listing"#,\#<div[^>]*class="col contact# {
	    /title="Detailinformationen/ b name
	    \#<h3>.*</h3># b name
	    /<p class="address/ b address
	}
	\#<div[^>]*class="col contact# {
	    g
	    s/\n/, /g
	    s/[,[:space:]]*$//
	    s/[ ]/ /g
	    p
	    q
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

_reverse_google_request() {
    # anonymize as far as possible (use only the first six digits)
    local number=$(expr substr "$1" 1 6)0000000000
    getmsg -w 4 "http://www.google.de/search?num=0&q=%s" "$number"
}
_reverse_google_extract() {
    sed -n -e '
	/Call-by-Call-Vorwahlen/{
	    s#.*/images/euro_phone.gif[^>]*>\([[:space:]]*<[^>]*>\)*[[:space:]]*##
	    s#[[:space:]]*<.*##
	    s#^Deutschland,[[:space:]]*##
	    p
	    q
	}
    '
}

_reverse_callmonitor_request() {
    # anonymize (use only the first six digits)
    local number=$(expr substr "$1" 1 6)
    getmsg -w 4 'http://callmonitor.berlios.de/vorwahl.php?number=%s' "$number" | sed -e "1,/^$CR\?$/d"
}
_reverse_callmonitor_extract() {
    local vorwahl ortsnetz
    read vorwahl ortsnetz
    echo "$ortsnetz"
}
