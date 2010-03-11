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
require cgi
require delivery

SELF=maint
TITLE='$(lang de:"Ereignisse" en:"Events")'

eval "$(modcgi show dump)"

cgi_begin "$TITLE" extras

cols="TIMESTAMP EVENT SOURCE DEST ID"
n=0
___() {
    let n++
##   if ? "n == DUMP_SHOW"; then
##	echo "<table>"
##	for var; do
##	    echo "<tr><th>$var</th>"
##	    eval 'echo "<td>$(html "$'"$var"'")</td>"'
##	done
##	echo "</table>"
##   else
##	echo -n "<a href='dump?show=$n'>"
##	echo -n "[$(html "$EVENT")] $(html "$SOURCE") ~ $(html "$DEST")"
##	echo "</a>"
	echo "<tr>"
	for var in $cols; do
	    eval 'echo "<td>$(html "$'"$var"'")</td>"'
	done
	echo "</tr>"
##   fi
##  echo "</li>"
}

if [ -d "$CALLMONITOR_DUMPDIR" ]; then
    echo "<table><tr>"
    for var in $cols; do echo "<th style='text-align: left;'>$var</th>"; done
    echo "</tr>"
    tmp=/tmp/callmonitor/$$
    mkdir -p "$tmp"
    packet_snapshot "$CALLMONITOR_DUMPDIR" "$tmp"
    for p in $(ls "$tmp"); do
	. "$tmp/$p"
    done
    rm -rf "$tmp"
    echo "</table>"
fi

cgi_end
