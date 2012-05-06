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
support phonebook
require tel
require hash
require file

ensure_file "$CALLMONITOR_LISTENERS"

export INSTANCE=0

## provider cache
new_hash _provider
_provider_name() {
    local provider=$1 name=
    _provider_get "$provider" name
    if have phonebook && empty "$name"; then
	name="$(_pb_main --local -- get "$provider") "
	_provider_put "$provider" "$name"
    fi
    echo "${name% }"
}

__incoming_call() {
    __prepare_env

    local event_spec source_pattern dest_pattern listener rule=0
    while readx event_spec source_pattern dest_pattern listener
    do
	## process rule asynchronously
	RULE=$rule \
	__process_rule "$event_spec" "$source_pattern" "$dest_pattern" "$listener" &
	let rule++
    done < "$CALLMONITOR_LISTENERS"
    wait
}

__prepare_env() {
    local __
    if ! empty "$SOURCE"; then
	case $EVENT,$PROVIDER in
	    out:*,SIP*) SOURCE_ENTRY=$(_provider_name "$PROVIDER") ;;
	    *) SOURCE_ENTRY=""; false ;;
	esac || {
	    if have phonebook; then
		SOURCE_ENTRY=$(_pb_main $SOURCE_OPTIONS -- get "$SOURCE")
	    fi
	}
    else ## empty "$SOURCE"
	case $EVENT in
	    out:*) SOURCE=$PROVIDER ;;
	esac
    fi
    if ! empty "$SOURCE"; then
	normalize_address "$SOURCE" display; SOURCE_DISP=$__
    fi
    if ! empty "$DEST"; then
	case $EVENT,$PROVIDER in 
	    in:*,SIP*) DEST_ENTRY=$(_provider_name "$PROVIDER") ;;
	    *) DEST_ENTRY=""; false ;;
	esac || {
	    if have phonebook; then
		DEST_ENTRY=$(_pb_main $DEST_OPTIONS -- get "$DEST")
	    fi
	}
    else ## empty "$DEST"
	case $EVENT in
	    in:*) DEST=$PROVIDER ;;
	esac
    fi
    if ! empty "$DEST"; then
	normalize_address "$DEST" display; DEST_DISP=$__
    fi

    ## split name into name and address
    case $SOURCE_ENTRY in
	*\;*)
	    SOURCE_ADDRESS=${SOURCE_ENTRY#*;}
	    SOURCE_ADDRESS=${SOURCE_ADDRESS# } 
	    SOURCE_NAME=${SOURCE_ENTRY%%;*}
	    ;;
	*)  SOURCE_ADDRESS= SOURCE_NAME=$SOURCE_ENTRY ;;
    esac
    case $DEST_ENTRY in
	*\;*)
	    DEST_ADDRESS=${DEST_ENTRY#*;}
	    DEST_ADDRESS=${DEST_ADDRESS# } 
	    DEST_NAME=${DEST_ENTRY%%;*}
	    ;;
	*)  DEST_ADDRESS= DEST_NAME=$DEST_ENTRY ;;
    esac

#<
    __info "[$INSTANCE] event detected:
  EVENT=$EVENT
  SOURCE='$SOURCE'
  DEST='$DEST'"
    __debug "[$INSTANCE+] detailed event data:
  SOURCE_DISP='$SOURCE_DISP'
  SOURCE_ENTRY='$SOURCE_ENTRY'
    SOURCE_NAME='$SOURCE_NAME'
    SOURCE_ADDRESS='$SOURCE_ADDRESS'
  DEST_DISP='$DEST_DISP'
  DEST_ENTRY='$DEST_ENTRY'
    DEST_NAME='$DEST_NAME'
    DEST_ADDRESS='$DEST_ADDRESS'
  ID=$ID
  EXT=$EXT
  DURATION=$DURATION
  TIMESTAMP='$TIMESTAMP'
  PROVIDER=$PROVIDER
  UUID=$UUID"
#>

    local var_cm="SOURCE DEST SOURCE_ENTRY DEST_ENTRY SOURCE_NAME DEST_NAME
	SOURCE_ADDRESS DEST_ADDRESS SOURCE_DISP DEST_DISP EVENT ID EXT DURATION
	TIMESTAMP PROVIDER UUID"

    ## make call information available to listeners
    export $var_cm

    ## dump information to file
    __dump $var_cm
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
    if [ $status -ne 0 ]; then
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
    local param=$1 value=$2 pattern=$3 result=1
    local regexp=${pattern#!}
    local shpat=${regexp#^}
    shpat=${shpat%\$}
    case $shpat in
	*[!A-Za-z_0-9-]*)
	    if echo "$value" | egrep -q "$regexp"; then
		result=0
	    fi
	    ;;
	*) # match simple patterns on our own
	    case $regexp in
		^*) ;;
		*) shpat="*$shpat" ;;
	    esac
	    case $regexp in
		*\$) ;;
		*) shpat="$shpat*" ;;
	    esac
	    case $value in
		$shpat) result=0 ;;
	    esac
	    ;;
    esac
    case $pattern in
	!*) let result="!result" ;;
    esac
    if [ $result -eq 0 ]; then
	__debug_rule "parameter $param='$value' matches pattern '$pattern'"
    else
	__debug_rule "parameter $param='$value' does NOT match" \
	    "pattern '$pattern'"
    fi
    return $result
}

__match_event() {
    local event=$1 spec=$2 dir= type= - result=1 ifs=$IFS IFS=, pattern
    set -f
    for pattern in $spec; do
	IFS=$ifs
	case $pattern in
	    ""|*:*:*)
		;;
	    *:*) 
		dir=${pattern%:*}
		type=${pattern#*:}
		case $event in $dir*:$type*) result=0;; esac
		;;
	    *) 
		case $event in $pattern*:*|*:$pattern*) result=0;; esac
		;;
	esac
	if [ $result -eq 0 ]; then
	    __debug_rule "event '$event' matches pattern '$pattern'"
	    break
	fi
    done
    if [ $result -eq 1 ]; then
	__debug_rule "event '$event' does NOT match pattern '$spec'"
    fi
    return $result
}
