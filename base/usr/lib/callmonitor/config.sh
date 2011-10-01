## requires /etc/default.callmonitor/callmonitor.cfg
if [ -r "$CALLMONITOR_USERCFG" ]; then
    . "$CALLMONITOR_USERCFG"
fi

## requires /usr/lib/callmonitor/system.sh
PATH=$CALLMONITOR_PATH
. "${CALLMONITOR_LIBDIR}/system.sh"
