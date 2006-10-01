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

## Syntax of rules in file $CALLMONITOR_LISTENERS (not compatible
## with versions 0.8 and less):
## 
## <event-spec> [!]<source-regexp> [!]<dest-regexp> <command line (rest)>
## 
## A command line is executed whenever an incoming call is detected that
## matches the event specification and both (egrep) regexps (source and dest).
## !-prefixed regexps must NOT match for the rule to succeed.
##
## Lines starting with "#" are ignored, as are empty lines.

## these stubs/defaults can be overridden (the configuration from system.cfg
## is needed, too; it must be included separately)
## 
## moved to callmonitor_config:
##   __debug() { true; }
##   __info() { true; }
incoming_call() { __incoming_call "$@"; }

require callmonitor_config
require if_jfritz
require phonebook
require hash
require file

ensure_file "$CALLMONITOR_LISTENERS"

export INSTANCE=0

## provider cache
new_hash _provider
_provider_name() {
    local provider=$1 name=
    _provider_get "$provider" name
    if empty "$name"; then
	name="$(_pb_main --local -- get "$provider") "
	_provider_put "$provider" "$name"
    fi
    echo "${name% }"
}

__incoming_call() {
    if ! empty "$SOURCE"; then
	case "$EVENT,$PROVIDER" in
	    out:*,SIP*) SOURCE_NAME=$(_provider_name "$PROVIDER") ;;
	    *) false ;;
	esac ||
	SOURCE_NAME=$(_pb_main $SOURCE_OPTIONS -- get "$SOURCE")
    else ## empty "$SOURCE"
	case $EVENT in
	    out:*) SOURCE=$PROVIDER ;;
	esac
    fi
    if ! empty "$DEST"; then
	case "$EVENT,$PROVIDER" in 
	    in:*,SIP*) DEST_NAME=$(_provider_name "$PROVIDER") ;;
	    *) false ;;
	esac ||
	DEST_NAME=$(_pb_main $DEST_OPTIONS -- get "$DEST")
    else ## empty "$DEST"
	case $EVENT in
	    in:*) DEST=$PROVIDER ;;
	esac
    fi
    __info "[$INSTANCE] EVENT=$EVENT SOURCE='$SOURCE' DEST='$DEST'" \
	"SOURCE_NAME='$SOURCE_NAME' DEST_NAME='$DEST_NAME'" \
	"ID=$ID EXT=$EXT DURATION=$DURATION TIMESTAMP='$TIMESTAMP'" \
	"PROVIDER=$PROVIDER"

    local var_cm="SOURCE DEST SOURCE_NAME DEST_NAME EVENT ID EXT DURATION
	TIMESTAMP PROVIDER"

    ## make call information available to listeners
    export $var_cm

    ## dump information to file
    __dump $var_cm

    local event_spec source_pattern dest_pattern listener rule=0
    while read -r event_spec source_pattern dest_pattern listener
    do
	## comment or empty line
	case $event_spec in \#*|"") continue ;; esac

	## process rule asynchronously
	RULE=$rule \
	__process_rule "$event_spec" "$source_pattern" "$dest_pattern" "$listener" &
	let rule++
    done < "$CALLMONITOR_LISTENERS"
    wait
}

## process a single rule
__process_rule() {
    local event_spec=$1 source_pattern=$2 dest_pattern=$3 listener=$4
    __debug_rule "processing rule '$event_spec' '$source_pattern' '$dest_pattern' '$listener'"

    ## match
    if ! {
	__match_event "$EVENT" "$event_spec" &&
	__match SOURCE "$SOURCE" "$source_pattern" &&
	__match DEST "$DEST" "$dest_pattern"
    } then 
	__debug_rule "FAILED"
	return 1
    fi

    ## execute listener
    __debug_rule "SUCCEEDED"
    __info_rule "ACTION: '$listener'"
    set --
    eval "$listener"
    local status=$?
    if ? "status != 0"; then
	__debug_rule "listener failed with an exit status of $status"
    fi

    return 0
}
__debug_rule() {
    __debug "[$INSTANCE:$RULE]" "$@"
}
__info_rule() {
    __info "[$INSTANCE:$RULE]" "$@"
}

## match a single pattern from a rule
__match() {
    local PARAM=$1 VALUE=$2 PATTERN=$3 RESULT=1
    local REGEXP=${PATTERN#!}
    local SHPAT=${REGEXP#^}
    SHPAT=${SHPAT%\$}
    case "$SHPAT" in
	*[!A-Za-z_0-9-]*)
	    if echo "$VALUE" | egrep -q "$REGEXP"; then
		RESULT=0
	    fi
	    ;;
	*) # match simple patterns on our own
	    case "$REGEXP" in
		^*) ;;
		*) SHPAT="*$SHPAT" ;;
	    esac
	    case "$REGEXP" in
		*\$) ;;
		*) SHPAT="$SHPAT*" ;;
	    esac
	    case "$VALUE" in
		$SHPAT) RESULT=0 ;;
	    esac
	    ;;
    esac
    case $PATTERN in
	!*) let RESULT="!RESULT" ;;
    esac
    if ? RESULT == 0; then
	__debug_rule "parameter $PARAM='$VALUE' matches pattern '$PATTERN'"
    else
	__debug_rule "parameter $PARAM='$VALUE' does NOT match" \
	    "pattern '$PATTERN'"
    fi
    return $RESULT
}

__match_event() {
    local event=$1 spec=$2 dir= type= - RESULT=1 ifs=$IFS IFS=,
    set -f
    for pattern in $spec; do
	IFS=$ifs
	case $pattern in
	    ""|*:*:*)
		;;
	    *:*) 
		dir=${pattern%:*}
		type=${pattern#*:}
		case $event in $dir*:$type*) RESULT=0;; esac
		;;
	    *) 
		case $event in $pattern*:*|*:$pattern*) RESULT=0;; esac
		;;
	esac
	if ? "RESULT == 0"; then
	    __debug_rule "event '$event' matches pattern '$pattern'"
	    break
	fi
    done
    if ? "RESULT == 1"; then
	__debug_rule "event '$event' does NOT match pattern '$spec'"
    fi
    return $RESULT
}
