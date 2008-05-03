#! /bin/ash
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
cfg_cat() {
    allcfgconv -C "$1" -c -o -
}
cfg_parse() {
    sed -ne '
	## trace nested elements in hold space
	/^[[:space:]]*[[:alnum:]][[:alnum:]_]* {/ {
	    s/^[[:space:]]*\([[:alnum:]][[:alnum:]_]*\).*/\1/; H; d
	}
	/^[[:space:]]*}[[:space:]]*$/ {
	    x; s/\(.*\)\n.*$/\1/; h; d
	}
        ## only single-line values for now
	/=.*;$/ {
	    ## append parents, swap, and clean up
	    G
	    s/^[[:space:]]*\(.*\)\n\n\(.*\)/\2\n\1/
	    s/\n/_/g
	    s/[[:space:]]*=[[:space:]]*/=/
	    s/[$`]/\\&/g
	    ## hack for arrays
	    s/ "/\\ "/g
	    p
	}
    '
}
cfg_top() {
    local pat="$1"
    sed -ne '/^'"$pat"'[[:space:]]*{/,/^}/p'
}
cfg() {
    case $# in
	2) cfg_cat "$1" | cfg_top "$2" | cfg_parse ;;
	1) cfg_cat "$1" | cfg_parse ;;
	*) return 1 ;;
    esac
}
case $0 in *cfg2sh) cfg "$@";; esac
