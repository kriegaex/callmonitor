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
    local type=$1  # '':text, 1:html
    default_mailmessage $type | sed -e "s/\$/$CR/"
}
default_mailmessage() { 
    local type=$1 p1 p2
    if ? 'type == 1'; then
	p1='<p>'
	p2='</p>\n'
    fi
    default_message '' '' $type
    echo "$p1"
    echo "$TIMESTAMP"
    echo -ne "$p2"
}
    
mailmessage() {
    mail_body | mail send -i - -s "$(mail_subject)" "$@"
}
mailmessage_html() {
    local html_file
    while true; do
	html_file=/tmp/mail_$(head -c4 /dev/urandom | hexdump -e '/4 "%04x"').html
	! [ -e "$html_file" ] && break
    done
    mail_body 1 > $html_file
    mail_body | mail send -i -,$html_file -s "$(mail_subject)" "$@"
    rm $html_file
}
## put a call to 'mail process' into your crontab in order to process mails
## that could not yet be delivered
