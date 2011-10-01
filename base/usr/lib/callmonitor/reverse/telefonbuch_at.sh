_reverse_telefonbuch_at_url() {
    local number="0${1#${LKZ_PREFIX}43}"
    URL="http://www.dasschnelle.at/index.php?pc=in&aktion=suchein&telnummer=$(urlencode "$number")"
}
_reverse_telefonbuch_at_request() {
    local URL=
    _reverse_telefonbuch_at_url "$@"
    wget_callmonitor -q -O - "$URL"
}
_reverse_telefonbuch_at_extract() {
    sed -n -e '
	/keine passenden Teilnehmer gefunden/ {
	    '"$REVERSE_NA"'
	}
	/<div class="ergebnis"/,/<div class="servicelinks"/ {
	    /<div class="adresse"/ b adresse
	}
	b
	
	: adresse
	\#</div># b cleanup
	/<div class="servicelinks"/ b cleanup
	s/$/, /g
	H
	n; b adresse
	
	: cleanup
	g
	s#<p class="name">\([^<]*\)</p>#<rev:name>&</rev:name>#
	s/<p class="telnummer".*//
	s#</p>#, #g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    ' | utf8_latin1
}
