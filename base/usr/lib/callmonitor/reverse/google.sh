_reverse_google_url() {
    ## anonymize as far as possible (use only the first nine digits)
    local number=$(expr substr "$1" 1 9)0000000000
    URL="http://www.google.de/search?num=1&q=$(urlencode "$number")"
}
_reverse_google_request() {
    local URL=
    _reverse_google_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_google_extract() {
    sed -n -e '
	/Call-by-Call-Vorwahlen/{
	    s#.*/images/euro_phone.gif[^>]*>\([[:space:]]*<[^>]*>\)*[[:space:]]*##
	    s#[[:space:]]*<.*##
	    s#^Deutschland,[[:space:]]*##
	    '"$REVERSE_SANITIZE"'
	    '"$REVERSE_OK"'
	}
	/Es wurden keine mit Ihrer Suchanfrage/ {
	    '"$REVERSE_NA"'
	}
    '
}
