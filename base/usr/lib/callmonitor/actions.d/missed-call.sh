require webui
require net

## remember to login first
latest_call() {
    local NUMBER="$1"
    wget "http://127.0.0.1/cgi-bin/webcm?getpage=../html/de/FRITZ!Box_Anrufliste.csv" -O - |
    fgrep ";$NUMBER;" | head -1
}

call_status() {
    case "$1" in
	1*) echo incoming ;;
	2*) echo missed ;;
	3*) echo outgoing ;;
	*) echo unknown ;;
    esac
}
call_date() {
    local dd='\([[:digit:]]\{2\}\)'
    echo "$1" | cut -d\; -f 2 |
	sed -e "s/^$dd\.$dd\.$dd $dd:$dd\$/"'\2\1\4\520\3/'
}

mail_call_subject() {
    case $STATUS in
	missed) echo "Verpasst: Anruf${SOURCE:+" von $SOURCE"}" ;;
	incoming) echo "Anruf${SOURCE:+" von $SOURCE"}" ;;
	*) echo "Anruf" ;;
    esac
}
mail_call_body() {
    {
	default_mail
	if [ "${CALL:+set}" ]; then
	    echo
	    echo "$CALL"
	fi
    } | sed -e "s/\$/$CR/"
}
default_mail() { default_message; }
    
mail_missed_call() {
    local start="$(date +%s)" time diff
    ## wait long enough for caller to give up
    sleep 60

    ## login to web interface and force refresh of list of phone calls
    webui_login
    webui_get "getpage=../html/de/menus/menu2.html&var:lang=de&var:menu=fon&var:pagename=foncalls" > /dev/null

    ## get call from log and check timestamp approximately (if the call has been
    ## accepted and has not finished yet, we might find old calls in the log)
    export CALL="$(latest_call "$SOURCE")"
    if [ -z "$CALL" ]; then 
	echo "could not find call from '$SOURCE' in log" >&2
	return 1
    fi
    time="$(date +%s -d "$(call_date "$CALL")")"
    if [ -z "$time" ]; then
	echo "did not understand time and date in '$CALL'" >&2
	return 1
    fi
    let diff="$time - $start"
    diff="${diff#-}" # abs()
    if [ "$diff" -gt 90 ]; then # +- 1.5 minutes
	echo "call '$CALL': time did not match (diff $diff)" >&2
	return 1
    fi
    
    export STATUS="$(call_status "$CALL")"
    echo "call status: $STATUS" >&2
    if [ "$STATUS" = missed ] ; then
	mail_call_body | mail send -i - -s "$(mail_call_subject)" "$@"
    fi
}
## put a call to 'mail process' into your crontab in order to process mails
## that could not yet be delivered
