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
. /usr/lib/libmodcgi.sh

html() {
    if ? "$# == 0"; then
	sed -e '
	    s/&/\&amp;/g
	    s/</\&lt;/g
	    s/>/\&gt;/g
	    s/'\''/\&apos;/g
	    s/"/\&quot;/g
	'
    else
	case $* in
	    *[\&\<\>\'\"]*) httpd -e "$*" ;;
	    *) echo "$*" ;;
	esac
    fi
}

pre() {
    echo -n "<pre>"
    html # stdin
    echo "</pre>"
}

config_button() {
    cat <<EOF
<form class="btn" action="/cgi-bin/pkgconf.cgi" method="get">
    <input type="hidden" name="pkg" value="callmonitor">
    <div class="btn"><input type="submit" 
	value="$(lang de:"Zur&uuml;ck" en:"Back")"></div>
</form>
EOF
}

_check() {
    local input=$1
    local alt key val found=false
    shift
    for alt; do
	key=${alt%%:*}
	val=${alt#*:}
	: ${val:=$key}
	if ! $found; then
	    case $input in
		$key) eval "${val}${suffix}=\$checked"; found=true; continue ;;
	    esac
	fi
	eval "${val}_chk="
    done
}
check()  suffix=_chk checked=" checked" _check "$@"
select() suffix=_sel checked=" selected" _check "$@"
