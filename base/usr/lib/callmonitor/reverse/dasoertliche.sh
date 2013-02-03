_reverse_dasoertliche_url() {
    local number="0${1#+49}"
    URL="http://www.dasoertliche.de/Controller?form_name=search_inv&ph=$(urlencode "$number")"
}
_reverse_dasoertliche_request() {
    local URL=
    _reverse_dasoertliche_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_dasoertliche_extract() {
   sed -n -e '
	: main
        \#Kein Teilnehmer gefunden:\|keine Treffer finden# {
	    '"$REVERSE_NA"'
	}
	\#<div[[:space:]]\+class="adresse\([[:space:]][^"]*\)\?"[[:space:]]*>#,\#<div[[:space:]]class="\(zusatz\|topx\)"# {
	    \#<div \+class="counter"# d
	    \#<script #,\#</script># d
	    s#^.*<a[[:space:]][^>]*class="preview[^"]*"[^>]*>\(.*\)$#\1#
	    t holdname
	    \#<div[[:space:]]class="\(zusatz\|topx\)"# b cleanup
	    H
        }
        b

        : holdname
	s#.*#<rev:name>&</rev:name>#
        h
	b

	: cleanup
	g
	s/\(<br\/>\)\?\n\|<br\/>/, /g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
