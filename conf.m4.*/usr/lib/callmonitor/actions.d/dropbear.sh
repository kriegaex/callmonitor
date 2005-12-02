#!/bin/sh
# start or stop ssh daemon
droptoggle() {
	dropoff || dropon
}

# start ssh daemon
dropon() {
	/usr/sbin/dropbear -p "$(get_it DROPPORT 22)"
}

# stop ssh daemon
dropoff() {
	killall -q dropbear
}
