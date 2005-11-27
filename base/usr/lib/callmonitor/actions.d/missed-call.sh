#!/bin/sh
require webui

# remember to login first
latest_call() {
	local NUMBER="$1"
	wget "http://127.0.0.1/cgi-bin/webcm?getpage=../html/de/FRITZ!Box_Anrufliste.csv" -O - |
	grep "$NUMBER" | head -1
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
	local dd='\([0-9][0-9]\)'
	echo "$1" | cut -d\; -f 2 |
		sed -e "s/^$dd\.$dd\.$dd $dd:$dd\$/"'\2\1\4\520\3/'
}

mail_call_subject() {
	case $STATUS in
		missed) echo "Verpasst: Anruf${MSISDN:+" von $MSISDN"}" ;;
		incoming) echo "Anruf${MSISDN:+" von $MSISDN"}" ;;
		*) echo "Anruf" ;;
	esac
}
mail_call_body() {
	{
		default_message
		if [ "${CALL:+set}" ]; then
			echo
			echo "$CALL"
		fi
	} | sed -e 's/$//'
}
	
mail_missed_call() {
	local start="$(date +%s)" time diff
	# wait long enough for caller to give up
	sleep 60

	# login to web interface and force refresh of list of phone calls
	webui_login
	webui_get "getpage=../html/de/menus/menu2.html&var:lang=de&var:menu=fon&var:pagename=foncalls" > /dev/null

	# get call from log and check timestamp approximately (if the call has been
	# accepted and has not finished yet, we might find old calls in the log)
	export CALL="$(latest_call "$MSISDN")"
	if [ -z "$CALL" ]; then return 1; fi
	time="$(date +%s -d "$(call_date "$CALL")")"
	if [ -z "$time" ]; then return 1; fi
	let diff="$time - $start"
	diff="${diff#-}" # abs()
	if [ "$diff" -gt 90 ]; then # +- 1.5 minutes
		return 1
	fi
	
	export STATUS="$(call_status "$CALL")"
	if [ "$STATUS" = missed ] ; then
		mail_call_body | mail send -i - -s "$(mail_call_subject)" "$@"
	fi
}
# put a call to 'mail process' into your crontab in order to process mails
# that could not yet be delivered
