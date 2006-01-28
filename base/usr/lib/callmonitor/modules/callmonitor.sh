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
## with versions in mod-0.57 and earlier):
## 
## [NT:|*:|E:][!]<source-regexp> [!]<dest-regexp> <command line (rest)>
## 
## A command line is executed whenever an incoming call is detected that
## matches both (egrep) regexps (source and dest). The prefix "NT:" to
## the source-regexp can be used to restrict matches to calls coming from
## the S0 bus ("Incoming from NT"); no prefix ignores these calls (the
## default); "*:" matches both. !-prefixed regexps must NOT match for the
## rule to succeed.
##
## The prefix "E:" matches ends of calls. It is not possible to distuingish
## between NT and not NT in this case.
## 
## Lines starting with "#" are ignored, as are empty lines.

require notify

## these stubs/defaults can be overridden (the configuration from system.cfg
## is needed, too; it must be included separately)
__debug() { true; }
__info() { true; }
incoming_call() { __incoming_call "$@"; }
PHONEBOOK_OPTIONS=""

__configure() {
    ## import action functions
    local ACTIONSDIR ACTIONS
    for ACTIONSDIR in "$CALLMONITOR_LIBDIR/actions.d" \
	"$CALLMONITOR_LIBDIR/actions.local.d"; do
	for ACTIONS in "$ACTIONSDIR"/*.sh; do
	    if [ -r "$ACTIONS" ]; then
		__debug "including $(realpath "$ACTIONS")"
		. "$ACTIONS"
	    fi
	done
    done
    if [ ! -d "$CALLMONITOR_VAR/notify" ]; then
	mkdir -p "$CALLMONITOR_VAR/notify"
    fi
}

## process an "IncomingCall" line
__incoming_call_line() {
    local line="$1"
    local SOURCE="${line##*caller: \"}"; SOURCE="${SOURCE%%\"*}"
    local DEST="${line##*called: \"}"; DEST="${DEST%%\"*}"
    local SOURCE_NAME="" DEST_NAME="" NT=false END=false
    local SOURCE_OPTIONS= DEST_OPTIONS=
    __debug "detected '$line'"
    case "$line" in
	*"IncomingCall from NT:"*) NT=true ;; 
    esac

    ## only one reverse lookup; it is expensive
    if $NT; then
	SOURCE_OPTIONS="--local"
    else
	DEST_OPTIONS="--local"
    fi
    incoming_call
}

## process an "outgoing" summary line at end of call
__end_outgoing_line() {
    local line="$1"
    local SOURCE="${line% outgoing*}"; SOURCE="${SOURCE##* }"
    local DEST="${line% ChargeU*}"; DEST="${DEST##* }" 

    ## NT cannot be detected; let's simply assume local outbound call
    local SOURCE_NAME="" DEST_NAME="" NT=true END=true
    local SOURCE_OPTIONS="--local" DEST_OPTIONS="--local"
    __debug "detected '$line'"
    incoming_call
}

## phone book look-up
__lookup() {
    if [ ! -z "$SOURCE" ]; then
	SOURCE_NAME="$(phonebook $PHONEBOOK_OPTIONS $SOURCE_OPTIONS \
	    get "$SOURCE")"
    fi
    if [ ! -z "$DEST" ]; then
	DEST_NAME="$(phonebook $PHONEBOOK_OPTIONS $DEST_OPTIONS \
	    get "$DEST")"
    fi
    __info "LOOKUP (SOURCE_NAME='$SOURCE_NAME' DEST_NAME='$DEST_NAME')"
}

## process a call
__incoming_call() {
    trap - CHLD
    __info "CALL (SOURCE='$SOURCE' DEST='$DEST' NT=$NT END=$END)" 

    if [ ! -r "$CALLMONITOR_LISTENERS" ]; then
	__info "$CALLMONITOR_LISTENERS is missing"
	return
    else
	__debug "processing rules from $CALLMONITOR_LISTENERS"
    fi
    
    ## perform phone book look-up during rule matching
    local DETAILS="$CALLMONITOR_VAR/notify/$$-$INSTANCE"
    local DETAILS_MONITOR="$DETAILS.m"
    trap "notifyall_fifo $DETAILS_MONITOR; rm -f $DETAILS" EXIT
    trap 'exit 2' HUP INT QUIT TERM
    mkfifo "$DETAILS_MONITOR"
    {
	__lookup
	{ echo "$SOURCE_NAME"; echo "$DEST_NAME"; } > "$DETAILS"
	notifyall_fifo "$DETAILS_MONITOR"
    } &

    ## make call information available to listeners
    export SOURCE DEST NT END

    ## deprecated interface
    export MSISDN="$SOURCE" CALLER="$SOURCE_NAME" CALLED="$DEST"

    local source_pattern dest_pattern listener
    export RULE=0
    while read -r source_pattern dest_pattern listener
    do
	## comment or empty line
	case $source_pattern in \#*|"") continue ;; esac
	__debug_rule "processing rule" \
	    "'$source_pattern' '$dest_pattern' '$listener'"

	## process rules asynchronously
	if __match_rule "$source_pattern" "$dest_pattern" "$listener"; then
	    
	    ## get detailed call information
	    wait_fifo "$DETAILS_MONITOR"
	    { read SOURCE_NAME; read DEST_NAME; } < "$DETAILS"
	    export SOURCE_NAME DEST_NAME
	    __execute_rule "$source_pattern" "$dest_pattern" "$listener"
	fi &

	let RULE++
    done < "$CALLMONITOR_LISTENERS"
    wait
}

# rule processing: condition part
__match_rule() {
    local source_pattern="$1" dest_pattern="$2" listener="$3"

    ## match NT/E prefix
    case $source_pattern in
	E:*)
	    if ! $END; then
		__debug_rule "is NOT END of call"
		__debug_rule "FAILED"
		return 1
	    fi
	    ;;
	*) 
	    if $END; then
		__debug_rule "is END of call"
		__debug_rule "FAILED"
		return 1
	    fi
	    ;;
    esac
    case $source_pattern in
	E:*|\*:*)
	    ## NT does not matter here
	    ;;
	NT:*)
	    if ! $NT; then 
		__debug_rule "call is NOT from NT"
		__debug_rule "FAILED"
		return 1
	    fi
	    ;;
	*)
	    if $NT; then 
		__debug_rule "call IS from NT"
		__debug_rule "FAILED"
		return 1
	    fi
	    ;;
    esac

    ## strip NT/*/E prefix
    case $source_pattern in
	NT:*|E:*|\*:*) source_pattern=${source_pattern#*:} ;;
    esac

    ## match
    __match SOURCE "$SOURCE" "$source_pattern" || return 1
    __match DEST "$DEST" "$dest_pattern" || return 1

    __debug_rule "SUCCEEDED"
    return 0
}

# rule processing: action part
__execute_rule() {
    local source_pattern="$1" dest_pattern="$2" listener="$3"
    __info_rule "ACTION ($source_pattern $dest_pattern $listener)"
    set --
    eval "$listener"
    local status=$?
    if [ $status -ne 0 ]; then
	__debug_rule "listener failed with an exit status of $status"
    fi

    return 0
}
__debug_rule() {
    __debug "[$RULE]" "$@"
}
__info_rule() {
    __info "[$RULE]" "$@"
}

## match a single pattern from a rule
__match() {
    local PARAM="$1" VALUE="$2" PATTERN="$3" RESULT=1
    local REGEXP="${PATTERN#!}"
    local SHPAT="${REGEXP#^}"
    SHPAT="${SHPAT%\$}"
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
	!*) let RESULT=!RESULT ;;
    esac
    if [ $RESULT -eq 0 ]; then
	__debug_rule "parameter $PARAM='$VALUE' matches pattern '$PATTERN'"
    else
	__debug_rule "parameter $PARAM='$VALUE' does NOT match" \
	    "pattern '$PATTERN'"
	__debug_rule "FAILED"
    fi
    return $RESULT
}

export INSTANCE=0

## copy stdin to stdout while looking for incoming calls
__read() {
    trap '' CHLD
    local line
    while IFS= read -r line
    do
	echo "$line"
	case $line in
	    *"IncomingCall"*"caller: "*"called: "*)
		__incoming_call_line "$line" &
		let INSTANCE++
	    ;;
	    *Slot:*ID:*CIP:*outgoing*)
		__end_outgoing_line "$line" &
		let INSTANCE++
	    ;;
	esac
    done
}
