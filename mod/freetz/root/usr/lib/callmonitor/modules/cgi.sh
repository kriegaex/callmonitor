##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2009  Andreas Bühmann <buehmann@users.berlios.de>
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

pre() {
    echo -n "<pre>"
    html # stdin
    echo "</pre>"
}

config_button() {
    echo "
<form class='btn' action='$(href cgi callmonitor)' method='get'>
    <div class='btn'><input type='submit' 
	value='$(lang de:"Konfiguration" en:"Configuration")'></div>
</form>
"
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
	eval "${val}${suffix}="
    done
}
check()  suffix=_chk checked=" checked" _check "$@"
select() suffix=_sel checked=" selected" _check "$@"

cgi_include() {
    local path=$1 file
    case $path in
	/*) ;;
	*) path="$CALLMONITOR_LIBDIR/web/$path" ;;
    esac
    if [ -d "$path" ]; then
	for file in $(ls "$path"/*); do
	    . "$file"
	done
    else
	. "$path"
    fi
}
