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
        \#Kein Teilnehmer gefunden:\|keine Treffer finden# {
            '"$REVERSE_NA"'
        }
        \#<div[[:space:]]\+class="hit[^>]\+id="entry_1#,\#</address[[:space:]]*># {
            \#<a[[:space:]]#,\#</a[[:space:]]*># {
                H
                \#</a># {
                    g
                    s#.*#<rev:name>&</rev:name>#
                    h
                }
            }
            \#<address#,\#</address[[:space:]]*># {
                H
                \#</address[[:space:]]*># b found
            }
        }
        b
        :found
        g
        '"$REVERSE_SANITIZE"'
        '"$REVERSE_OK"'
    '
}
