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

## start or stop ssh daemon
RC_DROPBEAR="/mod/etc/init.d/rc.dropbear"
droptoggle() {
    if [ -x "$RC_DROPBEAR" ]; then
	if [ "$("$RC_DROPBEAR" status)" = "running" ]; then
	    "$RC_DROPBEAR" stop
	else
	    "$RC_DROPBEAR" start
	fi
    fi
}

## start ssh daemon
dropon() {
    if [ -x "$RC_DROPBEAR" ]; then
	"$RC_DROPBEAR" start
    fi
}

## stop ssh daemon
dropoff() {
    if [ -x "$RC_DROPBEAR" ]; then
	"$RC_DROPBEAR" stop
    fi
}
