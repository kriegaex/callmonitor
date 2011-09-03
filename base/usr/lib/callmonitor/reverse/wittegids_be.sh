_reverse_wittegids_be_url() {
    local number="0${1#${LKZ_PREFIX}32}"
    URL="http://www.wittegids.be/q/name/telephone/$(urlencode "$number")/?customerType=ALL"
}
_reverse_wittegids_be_request() {
    local URL=
    _reverse_wittegids_be_url "$@"
    wget_callmonitor "$URL" -q -O -
}

_reverse_wittegids_be_extract() {
    sed -n -e '
	/Geen resultaten voor/ {
	    '"$REVERSE_NA"'
	}
	\#<span[^>]*class="result-title#,\#</span># {
	    H
	    \#</span># b name
	}
	\#<div class="result-address#,\#</div># {
	    H
	}
	\#<div class="result-icons# b output
	b
	: name
	g
	s#.*#<rev:name>&</rev:name>#
	h
	b
	: output
	g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
