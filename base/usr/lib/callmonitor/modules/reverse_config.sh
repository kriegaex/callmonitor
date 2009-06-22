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
require hash
## requires /usr/lib/callmonitor/reverse/provider.cfg

_reverse_init() {
    local type prov countries site label lkz entry cfg=

    ## validation
    for entry in $CALLMONITOR_REVERSE_PROVIDER; do
	lkz=${entry%:*}
	prov=${entry#*:}
	if grep -q "^R[^	]*	$prov	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	    cfg="$cfg $entry"
	fi
    done

    ## add missing default entries
    while readx type prov countries site label; do
	case $type in R*) ;; *) continue ;; esac
	case $countries in
	   *\!*)
		lkz=${countries%!*}
		lkz=${lkz##*,}
		case " $cfg" in
		    *" $lkz:"*) ;;
		    *) cfg="$cfg $lkz:$prov" ;;
		esac
		;;
	esac
    done < "$CALLMONITOR_REVERSE_CFG"

    ## this config covers every known country and refers only to valid
    ## providers
    REVERSE_PROVIDER=$cfg

    ## validate (and possibly correct) area provider
    if ! grep -q "^A[^	]*	$CALLMONITOR_AREA_PROVIDER	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	AREA_PROVIDER=
    else
	AREA_PROVIDER=$CALLMONITOR_AREA_PROVIDER
    fi

    new_hash REVERSE_PROVIDER
    for entry in $REVERSE_PROVIDER; do
	REVERSE_PROVIDER_put "${entry%:*}" "${entry#*:}"
    done

    unset -f _reverse_init
}
_reverse_init
