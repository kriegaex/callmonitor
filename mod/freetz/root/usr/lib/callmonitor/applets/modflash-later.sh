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

## modflash-later: flash at most $1 seconds later

require lock

FLASH=/tmp/flash
LATER_NAME=modflash-later
NOW_NAME=modflash-now
DEFAULT_MAX=600

DIR=$(dirname "$0")
NAME=$(basename "$0")

case $NAME in
    "$LATER_NAME")
	MAX=${1:-$DEFAULT_MAX}
	sleep "$MAX" &
	trap "kill $! 2> /dev/null; exit" TERM
	wait
	if lock "$FLASH"; then
	    ## in case something goes wrong
	    trap 'unlock "$FLASH"' EXIT

	    ## change name so we do not kill ourselves
	    exec "$DIR/$NOW_NAME"
	fi
	;;
    "$NOW_NAME")
	## kill all of our competitors
	killall -q "$LATER_NAME"
	modsave flash
	unlock "$FLASH"
	;;
esac
