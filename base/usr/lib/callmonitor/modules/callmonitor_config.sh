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
__debug() { true; }
__info() { true; }
__dump() { true; }

## requires /usr/lib/callmonitor/actions.local.d
__configure() {
    ## import action functions
    local actionsdir actions
    for actionsdir in "$CALLMONITOR_LIBDIR/actions.d" \
	"$CALLMONITOR_LIBDIR/actions.local.d"; do
	for actions in "$actionsdir"/*.sh; do
	    case $actions in *"/*.sh") continue ;; esac
	    __debug "including $(realpath "$actions")"
	    . "$actions"
	done
    done
}
