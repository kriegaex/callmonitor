## Listener types and common utilities; separate function for each type
## of listener. Put your own into $CALLMONITOR_LIBDIR/actions.local.d/*.sh
## 
## These environment variables are set by callmonitor before calling
## calling a listener:
##  SOURCE	source number
##  SOURCE_NAME source name
##  DEST	destination number
##  DEST_NAME	destination name

require net

## convert latin1 to utf8
latin1_utf8() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e '
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
    ' |
    while IFS= read -r line; do echo -ne "$line"; done
}

## get matching IPs from multid.leases and execute a command for each of them
## example: for_leases 192.168.10. dboxpopup "Ring!"
for_leases() {
    local IPS="$(fgrep -i "$1" /var/flash/multid.leases | awk '{ print $3 }')"
    local COMMAND="$2" IP=
    shift 2
    for IP in $IPS; do
	"$COMMAND" "$IP" "$@" &
    done
}

## simple *box listeners
dboxpopup() {
    getmsg -t "/control/message?popup=%s" -d default_dboxpopup "$@"
}
dboxmessage() {
    getmsg -t "/control/message?nmsg=%s" -d default_dboxmessage "$@"
}
default_dboxpopup() { default_dbox; }
default_dboxmessage() { default_dbox; }
default_dbox() {
    default_message | latin1_utf8 | sed -e 's/,[[:space:]]\+/\n/g'
}
dreammessage() {
    getmsg -t "/cgi-bin/xmessage?timeout=${TIMEOUT:-10}&caption=${CAPTION:-Telefonanruf}&body=%s" -d default_dreammessage "$@"
}
default_dreammessage() { default_message; }

## Usage: yac [OPTION]... [MESSAGE]
## Send a message to a yac listener (Yet Another Caller ID Program)
yac() {
    rawmsg -p 10629 -t "%s\0" -d default_yac "$@"
}
default_yac() {
    echo "@CALL$SOURCE_NAME~$SOURCE"
}

## Usage: vdr [OPTION]... [MESSAGE]
## Send a message to a VDR (Video Disk Recorder, http://www.cadsoft.de/vdr/)
vdr() {
    rawmsg -p 2001 -t "MESG %s\nQUIT\n" -d default_vdr "$@"
}
default_vdr() {
    echo "Anruf${SOURCE:+" $SOURCE"}${SOURCE_NAME:+" - $SOURCE_NAME"}"
}
