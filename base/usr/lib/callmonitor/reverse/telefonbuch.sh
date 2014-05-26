_reverse_telefonbuch_url() {
    local number="0${1#+49}"
    URL="http://www.dastelefonbuch.de/?la=de&kw=$(urlencode "$number")&cmd=search"
}

_reverse_telefonbuch_request() {
    local URL=
    _reverse_telefonbuch_url "$@"
    wget_callmonitor -q -O - "$URL" 2>&1
}
REVERSE_TELEFONBUCH_NBSP=$(echo -e '\xa0')
_reverse_telefonbuch_extract() {
    sed -n -e '
        /wget: server returned error: HTTP.* 410 Gone\|Kein Treffer gefunden/ {
            '"$REVERSE_NA"'
        }
        /<a id="name0"/,/<\/address>/ {
            /<a id="name0"/,/<\/a>/ {
                H
                /<\/a>/ {
                    g
                    s/.*/<rev:name>&<\/rev:name>/
                    h
                }
            }
            /<address class=/,/<\/address>/ {
                H
                /<\/address>/ b found
            }
        }
        b
        :found
        g
        s/'$REVERSE_TELEFONBUCH_NBSP'/ /g
        '"$REVERSE_DECODE_ENTITIES"'
        '"$REVERSE_SANITIZE"'
        '"$REVERSE_OK"'
   '
}
