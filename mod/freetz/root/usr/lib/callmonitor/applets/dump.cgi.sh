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

SELF=dump
TITLE='$(lang de:"Ereignisse" en:"Events")'

cgi_begin "$TITLE" extras

cols="TIMESTAMP EVENT SOURCE DEST ID"
n=0
___() {
    let n++
    echo "<tr>"
    for var in $cols; do
	eval 'echo "<td>$(html "$'"$var"'")</td>"'
    done
    echo "</tr>"
}

if [ -d "$CALLMONITOR_DUMPDIR" ]; then
    echo "<table><tr>"
    for var in $cols; do echo "<th style='text-align: left;'>$var</th>"; done
    echo "</tr>"
    tmp=/tmp/callmonitor/$$
    mkdir -p "$tmp"
    packet_snapshot "$CALLMONITOR_DUMPDIR" "$tmp"
    empty=true
    for p in $(ls "$tmp"); do
	. "$tmp/$p"
	empty=false
    done
    rm -rf "$tmp"
    echo "</table>"
    if $empty; then
	echo '$(lang de:"Keine Ereignisse" en:"No events")'
    fi
else
    echo '<p>$(lang 
	de:"Ereignisse werden nicht aufgezeichnet."
	en:"Events are not being recorded."
    )</p>'
fi

cgi_end
