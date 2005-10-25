# listeners.sh (callmonitor v0.3)
#
# Listener types and common utilities; separate function for each type
# of listener. Add your own!
#
# These environment variables are set by callmonitor before calling
# calling a listener:
#   MSISDN  caller's number
#   CALLER  caller's name
#   CALLED  number called

. "${CALLMONITOR_LIBDIR}/net.sh"

# convert latin1 to utf8
latin1_utf8() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -f /proc/self/fd/9 9<<-\EOF |
	s/ \([89ab]\)/c2\1/g
	s/ c/c38/g
	s/ d/c39/g
	s/ e/c3a/g
	s/ f/c3b/g
	s/ //g
	s/\(..\)/\\x\1/g
	EOF
    while IFS= read -r line; do echo -ne "$line"; done
}

# get matching IPs from multid.leases and execute a command for each of them
# example: for_leases 192.168.10. dboxpopup "Ring!"
for_leases() {
    local IPS="$(fgrep -i "$1" /var/flash/multid.leases | awk '{ print $3 }')"
    local COMMAND="$2" IP=
    shift 2
    for IP in $IPS
    do
	"$COMMAND" "$IP" "$@" &
    done
}

# simple *box listeners
dboxpopup() {
    getmsg -t "/control/message?popup=%s" "$@"
}
dboxmessage() {
    getmsg -t "/control/message?nmsg=%s" "$@"
}
dreammessage() {
    getmsg -t "/cgi-bin/xmessage?timeout=10&caption=Telefonanruf&body=%s" "$@"
}

# Usage: yac [OPTION]... [MESSAGE]
# Send a message to a yac listener (Yet Another Caller ID Program)
yac() {
    rawmsg -p 10629 -t "%s\0" -d default_yac "$@"
}
default_yac() {
    echo "@CALL$CALLER~$MSISDN"
}

# Usage: vdr [OPTION]... [MESSAGE]
# Send a message to a VDR (Video Disk Recorder, http://www.cadsoft.de/vdr/)
vdr() {
    rawmsg -p 2001 -t "MESG %s\nQUIT\n" -d default_vdr "$@"
}
default_vdr() {
    echo "Anruf $MSISDN - $CALLER"
}

# wake up all devices configured in debug.cfg
etherwakes() {
    local etheropt
    get_it ETHERWAKES |
    while read -r etheropt
    do
	/bin/etherwake $etheropt
    done
}

# start or stop ssh daemon
droptoggle() {
    dropoff || dropon
}

# start ssh daemon
dropon() {
    /usr/sbin/dropbear $(get_it DROPBEAR_OPTIONS "-p $(get_it DROPPORT 22)")
}

# stop ssh daemon
dropoff() {
    killall dropbear
}
