_reverse_adaffix_url() {
    URL="http://srv1.adaffix.com/adaffix/wap/wic.jsp?number=$(urlencode "$1")"
}
_reverse_adaffix_request() {
    local URL=
    _reverse_adaffix_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_adaffix_extract() {
    sed -n -e '
	/Nummer nicht im .*Telefonbuch/ {
	    '"$REVERSE_NA"'
	}

	\#<hr />#,/<td>Gefunden in/ {
	    \#<hr /># { h; b; }
	    /<td>Gefunden in/ b found
	    /<td><img/ d
	    s#<td><b>\(.*\)</b></td>#<rev:name>&</rev:name>#
	    s#</tr>#,#
	    H
	}
	b

	:found
	g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    ' | utf8_latin1
}
