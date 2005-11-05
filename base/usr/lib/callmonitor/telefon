#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. "${CALLMONITOR_CFG:=/mod/etc/default.callmonitor/system.cfg}"

case "$CALLMONITOR_TELEFON_IP" in
	"") exec telefon a127.0.0.1 ;;
	\*) exec telefon ;;
	*)  exec telefon "a$CALLMONITOR_TELEFON_IP" ;;
esac
