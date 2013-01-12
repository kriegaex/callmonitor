require net
require lock
require util
require reverse
require file
require usage
require webui
require tel
require fshash
require recode
require flash

_pb_CACHE_DIR="/var/cache/phonebook"
ensure_dir "$_pb_CACHE_DIR"
_pb_FONBUCH_CACHE="$_pb_CACHE_DIR/avm"

new_fshash _pb_avm "$_pb_FONBUCH_CACHE"
new_fshash _pb_cache "$CALLMONITOR_TRANSIENT"

ensure_file "$CALLMONITOR_PERSISTENT"
ensure_dir "$CALLMONITOR_TRANSIENT"

_pb_fonbuch_init() {
    local nu na
    if [ ! -e "$_pb_FONBUCH_CACHE" ]; then
        _pb_fonbuch_read | while readx nu na; do
	    normalize_address "$nu"
	    _pb_avm_put "$__" "$na"
        done
    fi
}
_pb_fonbuch() {
    local key value
    _pb_fonbuch_init
    _pb_list_hash _pb_avm
}
## convert a hash-based phonebook into flat-file form
_pb_list_hash() {
    local hash=$1 key value
    ${hash}_keys | while read -r key; do
    	${hash}_get "$key" value
    	echo "$key	$value"
    done
}
## requires /usr/www/all/html/callmonitor/fonbuch.txt
_pb_fonbuch_read() {
    webui_login && webui_get "getpage=../html/callmonitor/fonbuch.txt" | sed -e '
	1,/^$/d
	## remove the VIP flag
	s/^\([^	]*	\)!/\1/
    ' | {
	local line charset IFS=
	read -r line
	case $line in
	    *charset=utf-8*) utf8_latin1 ;;
	    *) cat ;;
	esac
    }
}

## Options to be overwritten before call of phonebook functions
_pb_REVERSE=false
case $CALLMONITOR_REVERSE in
    yes) _pb_REVERSE=true ;;
    no)  _pb_REVERSE=false ;;
esac

## Required functions
_pb_debug() { true; }

## Constant options set from config file
_pb_CACHE=true _pb_PERSISTENT=false 
case $CALLMONITOR_REVERSE_CACHE in
    no)  _pb_CACHE=false _pb_PERSISTENT=false ;;
    transient)	_pb_CACHE=true _pb_PERSISTENT=false ;;
    persistent) _pb_CACHE=true _pb_PERSISTENT=true ;;
esac

_pb_get() {
    local number=$1 number_norm name exitval __
    normalize_address "$number"; number_norm=$__
    _pb_get_local "$number_norm"
    exitval=$?; name=$__
    if [ $exitval -ne 0 ] && $_pb_REVERSE; then
	name=$(reverse_lookup "$number_norm")
	if [ $? -eq 0 ] && $_pb_CACHE; then
	    _pb_put_local "$number_norm" "$name" >&2 &
	    exitval=0
	fi
    fi
    echo "$name"
    return $exitval
}

_pb_get_local_pers() {
    _pb_find_number < "$CALLMONITOR_PERSISTENT"
}
_pb_get_local_trans() {
    _pb_cache_get "$number" name
}
_pb_get_local_avm() {
    [ "$CALLMONITOR_READ_FONBUCH" = yes ] || return
    _pb_fonbuch_init
    _pb_avm_get "$number" name
}
## for performance, _pb_get_local returns its result in $__
_pb_get_local() {
    local number=$1 name source
    for source in ${CALLMONITOR_PHONEBOOKS:-callers cache avm}; do
	if case $source in
	    callers) _pb_get_local_pers ;;
	    cache) _pb_get_local_trans ;;
	    avm) _pb_get_local_avm ;;
	    *) false ;;
	esac; then
	    _pb_debug "phone book '$source' contains {$number -> $name}"
	    __=$name
	    return 0
	fi
    done
    __=
    return 1
}
_pb_find_number() {
    local nu na
    while readx nu na; do
	normalize_address "$nu"
	if [ "$__" = "$number" ]; then name=$na; return 0; fi
    done
    return 1
}

_pb_put() {
    local number_plain=$1 name=$2 __
    normalize_address "$number_plain"
    _pb_put_local "$__" "$name"
}

_pb_remove() {
    MODE=remove _pb_put_or_remove "$@"
}
_pb_put_local() {
    MODE=put _pb_put_or_remove "$@"
}
_pb_put_or_remove() {
    local number=$1 name=$2 __

    ## where to put new number-name pairs
    if $_pb_PERSISTENT; then
	_pb_PHONEBOOK=$CALLMONITOR_PERSISTENT
    else
	_pb_PHONEBOOK=$CALLMONITOR_TRANSIENT
    fi

    case $MODE in 
	remove)
	    _pb_debug "removing $number from phone book $_pb_PHONEBOOK" ;;
	*)
	    _pb_norm_value "$name"; name=$__
	    _pb_debug "putting {$number -> $name} into phone book $_pb_PHONEBOOK"
	;;
    esac

    if $_pb_PERSISTENT; then
	## persistent storage as a small flat file
	local number_re=$(sed_re_escape "$number")
	## beware of concurrent updates
	if lock "$_pb_PHONEBOOK"; then
	    local tmpfile=$CALLMONITOR_TMPDIR/.callmonitor.tmp
	    { 
		sed -e "/^${number_re}[[:space:]]/d" "$_pb_PHONEBOOK" 2> /dev/null
		case $MODE in put)
		    echo "${number}	${name}" ;;
		esac
	    } > "$tmpfile"
	    mv "$tmpfile" "$_pb_PHONEBOOK"
	    unlock "$_pb_PHONEBOOK"
	else
	    _pb_debug "locking $_pb_PHONEBOOK failed"
	fi
	callmonitor_store
    else
	## Temporary storage as a fshash for quick access
	## Without locking because conflicts will be rare
	case $MODE in
	    put) _pb_cache_put "$number" "$name" ;;
	    remove) _pb_cache_remove "$number" ;;
	esac
    fi
}
## a value must always be a single line (we normalize whitespace as we go)
_pb_norm_value() {
    __=$(echo $(echo "$@" | sed -e '$!s/$/;/'))
}

## once at boot time
## requires /usr/lib/callmonitor/sipnames
_pb_init() {
    local sip="/var/run/phonebook/sip"
    ensure_file "$sip"
    "$CALLMONITOR_LIBDIR/sipnames" > "$sip"
}

## everytime callmonitor is started
_pb_start() {
    rm -rf "$_pb_CACHE_DIR"
    tel_config
    if [ "$CALLMONITOR_READ_FONBUCH" = "yes" ]; then
	echo -n "Reading AVM's phone book ... " >&2
	_pb_fonbuch_init
	echo "done." >&2
    fi
}

_pb_tidy() {
    local exitval=1
    local book=$CALLMONITOR_PERSISTENT
    echo -n "Tidying up $book: " >&2
    if lock "$book"; then
	echo -n "sorting and cleansing, " >&2
	local tmpfile=$CALLMONITOR_TMPDIR/.callmonitor.tmp
	sed -e '
	    /^[[:space:]]*$/d
	    s/^[[:space:]]*//
	    s/[[:space:]]\+/	/
	' "$book" | sort -u > "$tmpfile" && mv "$tmpfile" "$book"
	local max_length=0 num rest
	while readx num rest; do
	    let max_length="(${#num} > max_length ? ${#num} : max_length)"    
	done < "$book"
	while read -r num rest; do
	    case $num in \#*) echo "$num $rest"; continue ;; esac
	    printf "%-${max_length}s  %s\n" "$num" "$rest"
	done < "$book" > "$tmpfile" && mv "$tmpfile" "$book"
	exitval=$?
	rm -f "$tmpfile"
	unlock "$book"
    fi
    if [ $exitval -eq 0 ]; then
	callmonitor_store
    fi
    if [ $exitval -eq 0 ]; then
	echo "done." >&2
    else
	echo "failed." >&2
    fi
}

_pb_list() {
    case $1 in
	all)
	    _pb_list callers
	    echo
	    _pb_list cache
	    if [ "$CALLMONITOR_READ_FONBUCH" = yes ]; then
		echo
		_pb_list avm
	    fi
	    ;;
	cache)
	    echo "## cache ($CALLMONITOR_TRANSIENT)"
	    _pb_list_hash _pb_cache
	    ;;
	avm) 
	    echo "## avm ($_pb_FONBUCH_CACHE)"
	    _pb_fonbuch
	    ;;
	callers|*)
	    echo "## callers ($CALLMONITOR_PERSISTENT)"
	    cat "$CALLMONITOR_PERSISTENT" 2>/dev/null
	    ;;
    esac
    return 0
}

_pb_flush() {
    echo -n "Flushing temporary caches ... " >&2
    [ -d "$CALLMONITOR_TRANSIENT" ] && rm -rf "$CALLMONITOR_TRANSIENT"
    echo "done." >&2
}

_pb_main() {
    local _pb_REVERSE
    for arg; do
	case $arg in
	    --local) _pb_REVERSE=false; shift ;;
	    --) shift; break ;;
	esac
    done
    case $1 in
	get) _pb_get "$2" ;;
	exists) _pb_get "$2" > /dev/null ;;
	remove|rm) _pb_remove "$2" ;;
	put) _pb_put "$2" "$3" ;;
	list|ls) _pb_list "$2" ;;
	init|start|tidy|flush) "_pb_$1" ;;
	*) usage >&2; exit 1 ;;
    esac
    return $?
}

