_reverse_goyellow_url() {
    local number="0${1#${LKZ_PREFIX}49}"
    URL="http://www.goyellow.de/inverssuche/?TEL=$(urlencode "$number")"
}
_reverse_goyellow_request() {
    local URL=
    _reverse_goyellow_url "$@" 
    wget_callmonitor "$URL" -q -O -
}
_reverse_goyellow_extract() {
    local b=$'\1' e=$'\2'
    local c="[^$b$e]"
    sed -n -e '
	\#\(haben wir nichts\|Keine.*\) gefunden# {
	    '"$REVERSE_NA"'
	}
	\#<div id="searchResultListing"#,\#<p class="moreInfo"# {
	    \#<span class="normal fn# b name
	    \#<span class="\(comma\|postcode\|city \)# H
	    \#<span class="street encAdr"># b street
	    \#<span class="street # H
	}
	\#<p class="moreInfo"# {
	    g
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
	b
	: name
	s#.*#<rev:name>&</rev:name>#
	h
	b
	: street
	s#.*<span[^>]*>#'"$b$b$b"'#
	s#</span>.*#'"$e"'#
	H
	b
    ' | utf8_latin1 | sed -r "
    	: loop
	s/$b($c*)$b($c*)$b($c)($c)?/$b\1\3$b\4\2$b/
	t loop
	s/[$b$e]//g
    "
}
