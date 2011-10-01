_reverse_herold_at_url() {
    local number="0${1#${LKZ_PREFIX}43}"
    URL="http://www.herold.mobi/-/findlisting?what=$(urlencode "$number")&searchtype=WHITEPAGES"
}
_reverse_herold_at_request() {
    local URL=
    _reverse_herold_at_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_herold_at_extract() {
    sed -n -e '
	/Keine Ergebnisse/ {
	    '"$REVERSE_NA"'
	}
	# very fragile
	/^<div class="result"/,\#^</div># {
	    /<div class="highlight/,\#<br/>$# {
	    	\#<br/>$# b cleanup
	    	H
	    }
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
