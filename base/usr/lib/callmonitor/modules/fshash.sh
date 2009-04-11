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
## new_fshash <name> <root-path>
new_fshash() {
    local name=$1 root=$2 op
    for op in get put remove contains keys; do
	eval "${name}_${op}() _fshash_${op} \"$root\" \"\$@\""
    done
}

## convert the key into a file-system path; this is where the value gets stored
_fshash_hash() {
    local key=$1 head tail
    DIR= FILE=
    while true; do
	tail=${key#??}
	head=${key%"$tail"}
	if ! let "${head:+1}"; then
	    head=$tail
	    tail=
	fi  
	if ! let "${tail:+1}"; then
	    FILE="$head="
	    break
	else
	    DIR="$DIR/$head"
	    key=$tail
	fi
    done
}

_fshash_get() {
    local _root=$1 _key=$2 _var=$3 DIR FILE
    _fshash_hash "$_key"
    eval "$_var=\$(cat \"\$_root/\$DIR/\$FILE\" 2>/dev/null)"
}
_fshash_put() {
    local _root=$1 _key=$2 _value=$3 DIR FILE
    _fshash_hash "$_key"
    mkdir -p "$_root/$DIR" || return 1
    echo -n "$_value" > "$_root/$DIR/$FILE"
}
_fshash_remove() {
    local _root=$1 _key=$2 DIR FILE
    _fshash_hash "$_key"
    rm -f "$_root/$DIR/$FILE"
}
_fshash_contains() {
    local _root=$1 _key=$2 DIR FILE
    _fshash_hash "$_key"
    [ -e "$_root/$DIR/$FILE" ]
}
_fshash_keys() {
    local _root=$1
    ( cd "$_root"; find -type f; ) | sed -e 's#^.##;s#=$##;s#/##g'
}

## new_fshash a /some/dir/hash-root
## [... see hash.sh]
