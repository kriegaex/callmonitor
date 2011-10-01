## = Einstellungen =
##
## http://www.ip-phone-forum.de/showpost.php?p=525707&postcount=139
##
## [QUOTE=sucram]Hallo Andreas,
##
## kein Problem!
##
## Ich habe die Einstellungen noch einmal 'optimiert'. Mit den folgenden URLs
## lassen sich 4 Zeilen a 17 Zeichen darstellen.
##
## http://192.168.0.10/control/lcd?lock=1&clear=1&xpos=2&ypos=15&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=30&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=45&size=18&font=2&text=A000000000000000E&update=1
## http://192.168.0.10/control/lcd?lock=1&clear=0&xpos=2&ypos=60&size=18&font=2&text=A000000000000000E&update=1
## sleep 10
## http://192.168.0.10/control/lcd?lock=0
##
## sucram[/QUOTE]
##
## = API-Dokumentation =
##
## http://cvs.tuxbox.org/cgi-bin/viewcvs.cgi/tuxbox/apps/tuxbox/neutrino/daemons/nhttpd/api_doku.txt?view=markup

require net
require message
require recode

dboxlcd() {
    __getmsg dboxlcd -T dboxlcd -t "-" "$@"
}
__getmsg_dboxlcd() {
    local lcd="/control/lcd"
    local lcdtext="$lcd?xpos=1&size=17&font=2&text=%s"
    local line= init="&lock=1&clear=1" ypos=0
    local IFS=$LF
    echo "$*" |
    for ypos in 12 24 36 48 60; do
	read -r line
	if ! empty "$line"; then
	    TEMPLATE="$lcdtext&ypos=$ypos&update=1$init" __getmsg_simple "$line"
	    init=
	fi
    done
    sleep ${DBOX_TIMEOUT:-10}
    TEMPLATE="$lcd?lock=0" __getmsg_simple
}
default_dboxlcd() {
    default_message 19
}
encode_dboxlcd() {
    echo "$1" | latin1_utf8
}
