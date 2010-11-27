_reverse_billiger_url() {
    local number=$(expr substr "$1" 1 9)0000000000
    URL="http://www.billiger-telefonieren.de/vorwahlrechner/?num=$(urlencode "$number")"
}
_reverse_billiger_request() {
    local URL=
    _reverse_billiger_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_billiger_extract() {
    sed -n -e '
	/keine Tarife gespeichert/ {
	    '"$REVERSE_NA"'
	}
	s/^.*zur Rufnummer[^[]*\[\([^]]*\)\].*$/\1/
	t found
	b
	:found
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
