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
require format

## default message (multi-line)
default_message() {
    local cols=${1:-10000} lines=${2:-10000}
    
    local call="$(lang de:"Anruf" en:"Call")"
    local from="$(lang de:"von" en:"from")" to="$(lang de:"an" en:"to")"

    local here here_entry here_dir there there_entry there_dir
    case $EVENT in
	in:*)
	    there_dir=$from there=$SOURCE_DISP there_entry=$SOURCE_ENTRY
	    here_dir=$to here=$DEST_DISP here_entry=$DEST_ENTRY
	    ;;
	*)
	    here_dir=$from here=$SOURCE_DISP here_entry=$SOURCE_ENTRY
	    there_dir=$to there=$DEST_DISP there_entry=$DEST_ENTRY
	    ;;
    esac
    
    if ! empty "$here" && ? "lines > 1"; then
	echo "$call $here_dir ${here_entry:-$here}"
    elif ? "lines == 1"; then
	echo -n "$call "
    else
	echo "$call"
    fi
    if ! empty "$there"; then
	if ? "lines >= 3"; then
	    echo "$there_dir $there"
	    wrap "$cols" "$there_entry"
	else
	    echo "$there_dir ${there_entry:-$there}" | cut -c "1-$cols"
	fi
    fi
}

## one-liner
default_short_message() {
    default_message ${1:-50} 1
}


## wrap text (line length <= max)
wrap() {
    local max=${1:-10000} text=$2
    local len=${#text}
    if ? "len == 0"; then
	return
    elif ? "len <= max"; then
	echo "$text"
    else
	local a=1
	while ? "a <= len"; do
	    expr substr "$text" $a $max
	    let a+=max
	done
    fi
}
