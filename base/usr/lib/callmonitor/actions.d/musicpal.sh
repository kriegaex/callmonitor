## MusicPal (www.freecom.de)
##
## http://www.ip-phone-forum.de/showthread.php?p=1382302
## http://forum.freecompromo.com/viewtopic.php?t=8028

require net
require message

musicpalmessage() {
    getmsg -T musicpalmessage -U admin -P admin \
    	-t "/admin/cgi-bin/ipc_send?show_msg_box%%20%s%%a7%%23${MUSICPAL_TIMEOUT:-25}" -m 1 "$@"
}
musicpalclear() {
    getmsg -U admin -P admin \
    	-t "/admin/cgi-bin/ipc_send?menu_collapse" -m 0 "$@"
}
default_musicpalmessage() {
    default_message "" 2
}

## we need exactly (!) two non-empty lines, separated by '§' (\xA7)
encode_musicpalmessage() {
    { echo "$1"; echo; } | sed -n 's,§,/,g;s/^$/ /;1h;2{H;g;s/\n/§/g;p;q}'
}
