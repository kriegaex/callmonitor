_reverse_telefonbuch_url() {
    local number="0${1#+49}"
    URL="http://www.dastelefonbuch.de/?la=de&kw=$(urlencode "$number")&cmd=search"
}

_reverse_telefonbuch_request() {
    local URL=
    _reverse_telefonbuch_url "$@"
    wget_callmonitor -q -O - "$URL" 2>&1
}
_reverse_telefonbuch_extract() {
    sed -n -e '
        /wget: server returned error: HTTP.* 410 Gone\|Kein Treffer gefunden/ {
            '"$REVERSE_NA"'
        }
        /<a id="name0"/,/<\/address>/ {
            s/^[ \t]*//
            /<a id="name0"/,/<\/a>/ {
                /<\/a>/ {
                    s/^[ \t]*\(.*\)<\/a>/<rev:name>\1<\/rev:name>/
                    h
                }
            }
            /<address class=/,/<\/address>/ {
                /<\/address>/ {
                    s/<[^>]*>/#/g
                    s/&nbsp;/ /g
                    s/,/#/g
                    s/\([ \t]*#[ \t]*\)\+/#/g
                    s/#$//
                    H
                }
            }
        }
        $ {
            g
            s/\n//g
            s/#\+/\; /
            s/#\+/, /g
            '"$REVERSE_DECODE_ENTITIES"'
            '"$REVERSE_SANITIZE"'
            '"$REVERSE_OK"'
            p
        }
   '
}
