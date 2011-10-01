require message

mail_subject() {
    case $EVENT in
	in:cancel) echo -n "$(lang de:"Verpasst" en:"Missed"): " ;;
    esac
    case $EVENT in
	in:*) echo -n "$(lang de:"Anruf" en:"Call")${SOURCE_DISP:+" $(lang
	    de:"von" en:"from") $SOURCE_DISP"}" ;;
	out:*) echo -n "$(lang de:"Anruf" en:"Call")${DEST_DISP:+" $(lang
	    de:"an" en:"to") $DEST_DISP"}" ;;
    esac
    echo " [$EVENT]"
}
mail_body() {
    default_mailmessage | sed -e "s/\$/$CR/"
}
default_mailmessage() { 
    default_message
    echo
    echo "$TIMESTAMP"
}
    
mailmessage() {
    mail_body | mail send -i - -s "$(mail_subject)" "$@"
}
## put a call to 'mail process' into your crontab in order to process mails
## that could not yet be delivered
