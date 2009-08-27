## MusicPal (www.freecom.de)
##
## http://www.ip-phone-forum.de/showthread.php?p=1382302
## http://forum.freecompromo.com/viewtopic.php?t=8028
musicpalmessage() {
    getmsg -T musicpalmessage -U admin -P admin \
    	-t "/admin/cgi-bin/ipc_send?show_msg_box%%20%s%%a7%%a7%%23${MUSICPAL_TIMEOUT:-15}" -m 1 "$@"
}
musicpalclear() {
    getmsg -U admin -P admin \
    	-t "/admin/cgi-bin/ipc_send?menu_collapse" -m 0 "$@"
}
default_musicpalmessage() {
    default_message "" 2
}
encode_musicpalmessage() {
    echo "$1" | sed -n 's,§,/,g;1h;2,${H;g;s/\n/§/g;h};${g;p}'
}
