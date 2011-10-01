__debug() { true; }
__info() { true; }
__dump() { true; }

## requires /usr/lib/callmonitor/actions.local.d
__configure() {
    ## import action functions
    local actionsdir actions
    for actionsdir in "$CALLMONITOR_LIBDIR/actions.d" \
	"$CALLMONITOR_LIBDIR/actions.local.d"; do
	for actions in "$actionsdir"/*.sh; do
	    case $actions in *"/*.sh") continue ;; esac
	    __debug "including $(realpath "$actions")"
	    . "$actions"
	done
    done
}
