require cgi
require delivery

SELF=dump
TITLE='$(lang de:"Ereignisse" en:"Events")'

cgi_begin "$TITLE" extras

cols="TIMESTAMP EVENT SOURCE DEST ID"
n=0
___() {
    let n++
    echo "<tr>"
    for var in $cols; do
	case var in
	    TIMESTAMP|EVENT|SOURCE|DEST|ID)
		eval 'echo "<td>"${'"$var"'}</td>"'
	    ;;
	    *)
		eval 'echo "<td>$(html "${'"$var"}'")</td>"'
	    ;;
	esac
    done
    echo "</tr>"
}

if [ -d "$CALLMONITOR_DUMPDIR" ]; then
    echo "<table><tr>"
    for var in $cols; do echo "<th style='text-align: left;'>$var</th>"; done
    echo "</tr>"
    tmp=/tmp/callmonitor/$$
    mkdir -p "$tmp"
    packet_snapshot "$CALLMONITOR_DUMPDIR" "$tmp"
    empty=true
    for p in $(ls "$tmp"); do
	. "$tmp/$p"
	empty=false
    done
    rm -rf "$tmp"
    echo "</table>"
    if $empty; then
	echo '$(lang de:"Keine Ereignisse" en:"No events")'
    fi
else
    echo '<p>$(lang 
	de:"Ereignisse werden nicht aufgezeichnet."
	en:"Events are not being recorded."
    )</p>'
fi

cgi_end
