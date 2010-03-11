##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2010  Andreas Bühmann <buehmann@users.berlios.de>
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

## packets being created have a hyphen '-' prepended to their filename
packet_new() {
    local dir=$1 id=$2
    local date=$(date -u -Iseconds)
    if ! let "${id:+1}"; then
	id=$({ 
	    echo -n $$
	    dd if=/dev/urandom bs=16 count=1 2>/dev/null 
	} | md5sum)
	id=${id%% *}
    else
	id=$(printf "%016.16d" "$id")
    fi
    local name="$id"
    local complete="$dir/-$name"
    touch "$complete" || return 1
    echo "$complete"
    return 0
}

## deliver the packet by renaming it
packet_deliver() {
    local name=$1
    local target=${name%/-*}/${name##*/-}
    mv -f "$name" "$target"
}

packet_ls() {
    local dir=$1
    ls "$dir"/[^-]*
}

## remove all but $size packets (as well as stale packets)
packet_cleanup() {
    local dir=$1 size=$2
    ls -r "$dir"/[^-]* | tail -q -n "+${size:-15}" | xargs rm -f
    find "$dir" -maxdepth 1 -type f -name "-*" -mmin +15 | xargs rm -f
}

packet_snapshot() {
    local dir=$1 dir2=$2
    ln "$dir"/[^-]* "$dir2"/
}
