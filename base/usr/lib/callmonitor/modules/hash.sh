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
new_hash() {
    local name=$1 op
    for op in get put remove contains; do
	eval "${name}_${op}() _hash_${op} $name \"\$@\""
    done
}

_hash_get() {
    local name=$1 key=$2 var=$3
    eval "$var=\$_h_${name}_${key}"
}
_hash_put() {
    local name=$1 key=$2 value=$3
    eval "_h_${name}_${key}=\$value"
}
_hash_remove() {
    local name=$1 key=$2
    unset -v _h_${name}_${key}
}
_hash_contains() {
    local name=$1 key=$2
    eval "? \${_h_${name}_${key}+1}"
}

## new_hash a
## a_put 123 "foo"
## a_put 456 "lasijdflaisjdf"
## a_get 123 val
## echo $val
## a_get 456 val
## echo $val
## if a_contains 123; then echo yes; else echo no; fi
## a_remove 123
## a_get 123 val
## echo $val
## if a_contains 123; then echo yes; else echo no; fi
