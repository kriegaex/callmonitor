_reverse_local_ch_url() {
    local number="0${1#+41}"
    URL="http://mobile.tel.local.ch/de/q/?what=$(urlencode "$number")"
}
_reverse_local_ch_request() {
    local URL=
    _reverse_local_ch_url "$@"
    wget_callmonitor "$URL" -q -O -
}

_reverse_local_ch_extract() {
    sed -n -e '
	\#keine Eintr..\?ge gefunden# {
	    '"$REVERSE_NA"'
	}
	\#<div class="[^"]*\(bus\|res\)result# {
	    s#<div class="adr">\(\([^<]\|<\([^/]\|/\([^d]\|d[^i]\|di[^v]\)\)\)*\)</div>.*$# \1#
	    s#<p class="phoneNumber">\([^<]\|<[^/]\|</[^p]\|</p[^ >]\)*</p>##
	    s#^.*<div class="[^"]*\(bus\|res\)result"[^>]*>##
	    s#</\?a\(>\| [^>]*>\)##g
	    s#<h2 class="fn">\([^<]*\)</h2>#<rev:name>\1</rev:name>#
	    s#<br/>#,#g
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
    ' | utf8_latin1
}
