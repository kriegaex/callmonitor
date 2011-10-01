_reverse_search_ch_url() {
    local number="0${1#${LKZ_PREFIX}41}"
    URL="http://tel.search.ch/?tel=$(urlencode "$number")"
}
_reverse_search_ch_request() {
    local URL=
    _reverse_search_ch_url "$@"
    wget_callmonitor "$URL" -q -O -
}

_reverse_search_ch_extract() {
    sed -n -e '
	\#Keine Eintr..\?ge gefunden# {
	    '"$REVERSE_NA"'
	}
	\#^<div [^>]*class="tel_item"><div#,\#</div></div>$# {
	    \#<h5># b name
	    \#<span class="adrgroup# b address
	}
	b
	: name
	s#.*#<rev:name>&</rev:name>#
	h
	b
	: address
	H
	x
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
