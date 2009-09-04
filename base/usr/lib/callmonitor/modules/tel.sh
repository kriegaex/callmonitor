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
require webui
require file
require dump
require set

_tel_OKZ_CACHE="/var/cache/phonebook/telcfg"

normalize_address() {
    local number=$1
    # _pb_okz
    case $number in
	SIP*|*@*) normalize_sip "$@" ;;
	*) normalize_tel "$@" ;;
    esac
}

## normalize phone numbers
normalize_tel() {
    local number=$1 mode=$2 lkz=$LKZ
    unset __
    case $number in
	*[^0-9+*#]*) number=$(echo "$number" | tr -cd "0-9+*#")
    esac
    
    ## strip prefixes often used for special functions like CLIR
    case $number in
	[*#]*) number=${number##*[*#]} ;;
    esac

    ## stop early if any [*#] is left
    case $number in
	*[*#]*) __=$number; return 1 ;;
    esac

    case $number in
	+*) number="$LKZ_PREFIX${number#+}" ;;
    esac
    case $number in
	$LKZ_PREFIX*)
	    lkz=$(tel_lkz "$number")
	    number=$OKZ_PREFIX${number#$LKZ_PREFIX$lkz}
	;;
    esac
    # number is local to country
    case $lkz in
	49)
	    case $number in
	    ## remove call-by-call prefix
		010[1-9]?*)	number=${number#010[1-9]?} ;;
		0100??*)	number=${number#0100??} ;;
	    ## heuristic for missing LKZ_PREFIX
		49*) ? "${#number} > 10" && number=0${number#49} ;;
	    esac
    esac
    case $number in
	$OKZ_PREFIX*) ;;
	*) number="${OKZ_PREFIX}${OKZ}$number" ;;
    esac

    case $mode in
	display)
	    case $lkz in
		$LKZ)
		    case $number in
			$OKZ_PREFIX$OKZ*) __=${number#$OKZ_PREFIX$OKZ} ;;
			*) __=$number ;;
		    esac
		;;
		*) __="+$lkz${number#$OKZ_PREFIX}" ;;
	    esac
	    ;;
	save) __="+$lkz${number#$OKZ_PREFIX}" ;;
	*) __="${LKZ_PREFIX}${lkz}${number#$OKZ_PREFIX}" ;;
    esac
    return 0
}

tel_collect_lkzs() {
    local IFS="$IFS," -; set -f
    local type provider countries site label c
    LKZ_LIST=
    while readx type provider countries site label; do
	for c in $countries; do
	    [ "$c" = "*" ] && continue
	    set_add LKZ_LIST "${c%!}"
	done
    done < "$CALLMONITOR_REVERSE_CFG"
}

## recognize country prefixes
tel_lkz() {
    local number=$1 lkz
    case $number in
	$LKZ_PREFIX*) number=${number#$LKZ_PREFIX} ;;
	*) return 2 ;;
    esac
    for lkz in $LKZ_LIST; do
	case $number in
	    $lkz*) echo $lkz; return 0 ;;
	esac
    done
    return 1
}

## transform SIP[0-9] into SIP addresses
normalize_sip() {
    local number=$1
    case $number in
	SIP[0-9])
	    if eval "? \"\${${number}_address+1}\""; then
		eval "number=\"\$${number}_address\""
	    fi
	    ;;
    esac
    __=$number
    return 0
}
## read SIP[0-9] to address mapping
if [ -r /var/run/phonebook/sip ]; then
    . /var/run/phonebook/sip
fi

## retrieve OKZ et al. from AVM config
tel_config() {
    if [ ! -r "$_tel_OKZ_CACHE" ]; then
	webui_login
	ensure_file "$_tel_OKZ_CACHE"
	webui_query \
	    telcfg:settings/Location/LKZPrefix \
	    telcfg:settings/Location/LKZ \
	    telcfg:settings/Location/OKZPrefix \
	    telcfg:settings/Location/OKZ |
	tr -cd '0-9\n' |
	{
	    read LKZ_PREFIX
	    read LKZ
	    read OKZ_PREFIX
	    read OKZ
	    ## sensible defaults 
	    : ${LKZ_PREFIX:=00} ${LKZ:=49} ${OKZ_PREFIX:=0}
	    dump_var LKZ_PREFIX LKZ OKZ_PREFIX OKZ
	} > "$_tel_OKZ_CACHE"
    fi
    . "$_tel_OKZ_CACHE"
    tel_collect_lkzs
}

tel_config
