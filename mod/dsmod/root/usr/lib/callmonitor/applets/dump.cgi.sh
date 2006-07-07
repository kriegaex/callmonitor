##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
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
require lock

SELF=maint
TITLE='$(lang de:"Ereignisse" en:"Events")'

eval "$(modcgi show dump)"

cgi_begin "$TITLE" extras

cols="EVENT SOURCE DEST TIMESTAMP"
n=0
___() {
    let n++
    #if ? "n == DUMP_SHOW"; then
#	echo "<table>"
#	for var; do
#	    echo "<tr><th>$var</th>"
#	    eval 'echo "<td>$(httpd -e "$'"$var"'")</td>"'
#	done
#	echo "</table>"
#   else
#	echo -n "<a href='dump?show=$n'>"
#	echo -n "[$(httpd -e "$EVENT")] $(httpd -e "$SOURCE") ~ $(httpd -e "$DEST")"
#	echo "</a>"
	echo "<tr>"
	for var in $cols; do
	    eval 'echo "<td>$(httpd -e "$'"$var"'")</td>"'
	done
	echo "</tr>"
#   fi
#  echo "</li>"
}

if [ -r "$CALLMONITOR_DUMPFILE" ]; then
    echo "<table><tr>"
    for var in $cols; do echo "<th style='text-align: left;'>$var</th>"; done
    echo "</tr>"
    if lock "$CALLMONITOR_DUMPFILE"; then
	. "$CALLMONITOR_DUMPFILE"
	unlock "$CALLMONITOR_DUMPFILE"
    fi
    echo "</table>"
fi

cgi_end
