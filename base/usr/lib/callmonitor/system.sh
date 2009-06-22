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

## efficient boolean expressions with 'let': some syntactic sugar
## (busybox 1.2.1: no longer necessary; 'test' ('[') is a built-in!
__is_true() {
    let "$*"
}
alias \?=__is_true

empty() {
    ! let "${*:+1}"
}

## utilities for managing "libraries"
require() {
    local lib=$1; shift
    local file=${CALLMONITOR_LIBDIR}/modules/$lib.sh
    if ? "LIB_$lib != 1"; then
	. "$file" "$@"
	let "LIB_$lib = 1"
    fi
}

support() {
    local lib=$1; shift
    local file=${CALLMONITOR_LIBDIR}/modules/$lib.sh
    [ -e "$file" ] && require "$lib"
}

## feature sets
have() {
    [ -e "${CALLMONITOR_LIBDIR}/features/$1" ]
}
