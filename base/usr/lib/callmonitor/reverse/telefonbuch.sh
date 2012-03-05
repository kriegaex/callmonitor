_reverse_telefonbuch_url() {
    local number="0${1#+49}"
    URL="http://www.dastelefonbuch.de/?la=de&kw=$(urlencode "$number")&cmd=search"
}
_reverse_telefonbuch_request() {
    local URL=
    _reverse_telefonbuch_url "$@"
    wget_callmonitor -q -O - "$URL" 2>&1
}
_reverse_telefonbuch_extract() {
    sed -n -e '
	/wget: server returned error: HTTP.* 410 Gone\|kein Teilnehmer gefunden/ {
	    '"$REVERSE_NA"'
	}
	/<table[^>]*class="[^"]*\(bg-0[12]\|entry\)/,\#<td class="col4"# {
	    \#<div class="[^"]*hide#,\#</div># b
	    s#<br />#,#
	    H
	    \#<td class="col3"# b cleanup
	}
	b
	: cleanup
	g
	s/'$'\r''\?\n/ /g
	s#<a [^>]*href[^>]*>\(.*\)</a>#<rev:name>&</rev:name>#
	'"$REVERSE_DECODE_ENTITIES"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
