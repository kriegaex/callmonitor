require net
require recode
require tel
require reverse_config
## requires /usr/lib/callmonitor/reverse/*.sh

## resolve numbers to names and addresses; returns 1 if no lookup
## performed or if there were errors (no need to cache)
##
## The resulting name and address should be returned in Latin-1 encoding

reverse_lookup() {
    local number_plain=$1 prov area_prov child afile name exit number __
    normalize_address "$number_plain" || return 1
    number=$__
    if ! let "${number:+1}"; then return 1; fi

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
	    echo "$(normalize_address "$number" display; echo $__); $name"
	    exit=0
	fi
    fi
    { kill "$child" 2>/dev/null; rm -f "$afile"; } &
    return $exit
}
_reverse_choose_provider() {
    local lkz=$1
    REVERSE_PROVIDER_get "$lkz" prov
    area_prov=$AREA_PROVIDER
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

_reverse_lookup_url() {
    local prov=$1 number=$2 URL=
    _reverse_${prov}_url "$number"
    echo "$URL"
}

## sed snippets used by provider plugins

readonly REVERSE_OK='s/^/OK:/; p; q'
readonly REVERSE_NA='s/.*/NA:/; p; q'

readonly REVERSE_DECODE_ENTITIES='
    s#&uuml;#ü#g
    s#&auml;#ä#g
    s#&ouml;#ö#g
    s#&Uuml;#Ü#g
    s#&Auml;#Ä#g
    s#&Ouml;#Ö#g
    s#&szlig;#ß#g
'
readonly REVERSE_DECODE_ENTITIES_UTF8='
    s#&uuml;#'$'\xc3\xbc''#g
    s#&auml;#'$'\xc3\xa4''#g
    s#&ouml;#'$'\xc3\xb6''#g
    s#&Uuml;#'$'\xc3\x9c''#g
    s#&Auml;#'$'\xc3\x84''#g
    s#&Ouml;#'$'\xc3\x96''#g
    s#&szlig;#'$'\xc3\x9f''#g
'
readonly REVERSE_SANITIZE='
    s#</rev:name>#\&PART;#g
    s#<[^>]*># #g
    s#&nbsp;# #g
    s#&lt;#<#g
    s#&gt;#>#g
    s#&quot;#"#g
    s#&apos;#'\''#g
    s#|#,#g
    s#&PART;#|#g
    s#&\([^a]\|a[^m]\|am[^p]\|amp[A-Za-z]\)[A-Za-z]*;##g
    s#&amp;#\&#g
    s#;#,#g
    s#|#;#g
    s#\([[:space:]]\|Â \)\+# #g
    s#,\( *,\)\+#,#g
    s#; *,#;#g
    s#, *;#;#g
    s#^[,; ]*##
    s# \([],;)]\)#\1#g
    s#\([([]\) #\1#g
    s#[,; ]*$##
'

## initialization: load required provider modules

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
    for entry in $REVERSE_PROVIDER $AREA_PROVIDER; do
	prov=${entry#*:}
	_reverse_load "$prov"
    done
    unset -f _reverse_init
}
_reverse_init
