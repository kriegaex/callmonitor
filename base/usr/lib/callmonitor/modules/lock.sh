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

## lock $file by creating a symlink $file.lock -> PID;
lock() {
    local file=$1 interval=${2:-1000000} first=true
    ## race conditions between touch and realpath still possible
    if [ ! -e "$1" ] && ! touch "$1"; then
	return 1
    fi
    file=$(lock_filename "$file")
    local lock=$file.lock
    if ? $$ == $(read_lock_pid "$lock")+0; then
	## process already has lock
	return 0
    fi
    while ! ln -s $$ "$lock" 2> /dev/null; do
	if $first; then 
	    first=false
	    echo "Waiting for exclusive lock on $file" >&2
	fi
	usleep $interval
    done
    return 0
}

unlock() {
    local file=$(lock_filename "$1")
    local lock=$file.lock
    if ? $$ == $(read_lock_pid "$lock")+0; then
	rm "$lock"
    fi
}

read_lock_pid() {
    local lock=$1 pid=
    if [ ! -L "$lock" ]; then return 1; fi
    pid=$(/bin/ls -l "$lock")
    echo ${pid#*-> }
}
