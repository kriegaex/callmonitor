_reverse_telefonbuch_at_url() {
    local number="0${1#+43}"
    URL="http://www.dasschnelle.at/result/index/results?what=$(urlencode "$number")&resultsPerPage=1"
}
_reverse_telefonbuch_at_request() {
    local URL=
    _reverse_telefonbuch_at_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_telefonbuch_at_extract() {
    sed -n -e '
	/countResults : "0"/ {
	    '"$REVERSE_NA"'
	}
	/^[[:space:]]*entries : \[[[:space:]]*$/,/^[[:space:]]result : / {
	    /^[[:space:]]*\(name\|strasse\|plz\|ort\) : / b json
	}
	/^[[:space:]]*result : / b cleanup
	$ b cleanup
	b

	: json
	s#^[[:space:]]*\([a-z]\+\) : "\(.*\)",[[:space:]]*$#<\1>\2</\1>#
	s#\\[bfnrt]##g
	s#\\\(["\\/]\)#\1#g
	# \u four-hex-digits is not handled
	H
	b
	
	: cleanup
	g
	s#\(</\?\)name>#\1rev:name>#g
	s#</strasse>#&, #
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    ' | utf8_latin1
}
