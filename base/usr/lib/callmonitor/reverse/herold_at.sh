_reverse_herold_at_url() {
    local number="0${1#+43}"
    URL="http://www.herold.mobi/redirect/findlisting?what=$(urlencode "$number")&searchtype=WHITEPAGES"
}
_reverse_herold_at_request() {
    local URL=
    _reverse_herold_at_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_herold_at_extract() {
    sed -n -e '
	/keine Treffer/ {
	    '"$REVERSE_NA"'
	}
	# very fragile
	/^[[:space:]]*<div class="result_parent"/,\#<br/>[[:space:]]*$# {
	    \#<br/>[[:space:]]*$# b cleanup
	    H
	}
	b
	
	: cleanup
	g
	s#.*<b>\([^<]*\)</b>#<rev:name>\1</rev:name>#
	s#<br/>#, #g
	'"$REVERSE_DECODE_ENTITIES_UTF8"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    ' | utf8_latin1
}
