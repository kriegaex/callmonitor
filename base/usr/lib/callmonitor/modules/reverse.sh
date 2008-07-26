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
require net
require recode
require tel

## resolve numbers to names and addresses; the number is
## used as given (should be normalized beforehand); returns 1 if no lookup
## performed or if there were errors (no need to cache)
##
## The resulting name and address should be returned in Latin-1 encoding

reverse_lookup() {
    local number=$1 prov area_prov child afile name exit
    case $number in
	*[^0-9]*) return 1;
    esac
    local lkz=$(tel_lkz "$number")
    _reverse_choose_provider "$lkz"

    afile="/var/run/phonebook/lookup-$area_prov-$number"
    _reverse_lookup "$area_prov" "$number" | _reverse_atomic "$afile" & child=$!
    name=$(_reverse_lookup "$prov" "$number"); exit=$?
    if ! empty "$name"; then
	echo "$name"
	exit=0
    else
	## wait for area provider to finish
	wait $child
	name=$(cat "$afile" 2>/dev/null); exit=$?
	if ! empty "$name"; then
	    ## $name is only country/city
	    echo "$(normalize_address "$number" display; echo $__) ($name)"
	    exit=0
	fi
    fi
    { kill "$child" 2>/dev/null; rm -f "$afile"; } &
    return $exit
}
_reverse_choose_provider() {
    local lkz=$1 entry choice
    for entry in $CALLMONITOR_REVERSE_PROVIDER; do
	case $entry in
	    $lkz:*) choice=${entry#*:}; break ;;
	esac
    done
    if grep -q "^R[^	]*	$choice	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	prov=$choice
    else
	prov=$(grep "$lkz!" "$CALLMONITOR_REVERSE_CFG" | cut -f2)
    fi
    if grep -q "^A[^	]*	$CALLMONITOR_AREA_PROVIDER	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	area_prov=$CALLMONITOR_AREA_PROVIDER
    else
	area_prov=
    fi
}
_reverse_atomic() {
    local file=$1 tmp=$1.tmp
    cat > "$tmp" && mv "$tmp" "$file" || rm "$tmp"
}

_reverse_lookup() {
    local exit=0 result
    result=$(_reverse_query_provider "$@"); exit=$?
    case $result in
	OK:*) echo "${result#OK:}"; return 0 ;;
	NA:*) echo ""; return 1 ;;
	*)    echo ""; return 2 ;;
    esac
}

readonly REVERSE_OK='s/^/OK:/; p; q'
readonly REVERSE_NA='s/.*/NA:/; p; q'

_reverse_query_provider() {
    local prov=$1 number=$2 exit=0
    if empty "$prov"; then return 0; fi
    eval $({
	{ _reverse_${prov}_request "$number"; echo exit=$? >&4; } |
	_reverse_${prov}_extract
    } 4>&1 >&9)
## 141: nc: Broken pipe
    return $(( exit == 141 ? 0 : exit ))
} 9>&1

readonly REVERSE_SANITIZE='
    s#<[^>]*># #g
    s#&nbsp;# #g
    s#&amp;#\&#g
    s#&lt;#<#g
    s#&gt;#>#g
    s#&quot;#"#g
    s#&apos;#'\''#g
    s#[[:space:] ]\+# #g
    s#,\( *,\)\+#,#
    s#^[, ]*##
    s# \([,)]\)#\1#g
    s#\([(]\) #\1#g
    s#[, ]*$##
'

## initialization: load needed provider modules

_reverse_load() {
    local provider=$1
    if [ -z "$provider" ]; then return; fi
    local file=$CALLMONITOR_LIBDIR/reverse/$provider.sh
    if [ -e "$file" ]; then
	. "$file"
    fi
}
_reverse_init() {
    local entry prov
    for entry in $CALLMONITOR_REVERSE_PROVIDER $CALLMONITOR_AREA_PROVIDER; do
	prov=${entry#*:}
	_reverse_load "$prov"
    done
    unset -f _reverse_init
}
_reverse_init
