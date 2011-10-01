## requires /usr/lib/callmonitor/modflash-later
callmonitor_store() {
    "$CALLMONITOR_LIBDIR/modflash-later" > /dev/null 2>&1 &
}
