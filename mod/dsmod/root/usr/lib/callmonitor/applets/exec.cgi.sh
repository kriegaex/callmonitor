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
require if_jfritz_status

eval "$(modcgi jfritz exec)"
cgi_begin callmonitor

case $EXEC_JFRITZ in
    on)
	_j_enable
	echo "$(lang 
	    de:"JFritz-Schnittstelle eingeschaltet."
	    en:"JFritz interface enabled."
	)"
	;;
    off)
	_j_disable
	echo "$(lang 
	    de:"JFritz-Schnittstelle ausgeschaltet."
	    en:"JFritz interface disabled."
	)"
	;;
esac

config_button
cgi_end
