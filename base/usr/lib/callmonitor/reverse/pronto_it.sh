_reverse_pronto_it_url() {
    local number="0${1#+39}"
    URL="http://pronto.it/?q=$(urlencode "$number")"
}
_reverse_pronto_it_request() {
    local URL=
    _reverse_pronto_it_url "$@"
    wget_callmonitor "$URL" -q -O -
}

_reverse_pronto_it_extract() {
    sed -n -e '
    	/Non ho trovato/ {
	    '"$REVERSE_NA"'
	}
	\#<div class="blocco_info"#,\#</div># {
	    \#<span class="cognome# b name
	    \#<span class="via"# H
	    \#</div># b output
	}
	b
	: name
	s#.*#<rev:name>&</rev:name>#
	h
	b
	: output
	g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
