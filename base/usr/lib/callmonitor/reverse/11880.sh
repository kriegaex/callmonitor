_reverse_11880_url() {
    local number="0${1#+49}"
    URL="http://www.11880.com/inverssuche/index/search?method=searchSimple&_dvform_posted=1&phoneNumber=$(urlencode "$number")"
}
_reverse_11880_request() {
    local URL=
    _reverse_11880_url "$@"
    wget_callmonitor "$URL" -q -O - 
}
_reverse_11880_extract() {
    sed -n -e '
	/class="noResultCities"\|keinen Teilnehmer ermitteln/ {
	    '"$REVERSE_NA"'
	}
	/<[^[:space:]>]*[[:space:]]class="head[[:space:]]/,/<[^[:space:]>]*[[:space:]]class="numericdata/ {
	    /<[^[:space:]>]*[[:space:]]class="numericdata/ b found
	    /<a href=[^>]*#ratings/ d
	    H
	}
	b
	: found
	g
	s#<a class="namelink"[^>]>#<rev:name>#
	s#</a>#</rev:name>#
	s#<br />#, #g
	'"$REVERSE_DECODE_ENTITIES"'
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
