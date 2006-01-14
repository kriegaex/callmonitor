## utilities for managing "libraries"

require() {
    local lib="$1"
    local file="${CALLMONITOR_LIBDIR}/$lib.sh"
    if [ ! -e "$file" ]; then
	echo "require $lib: '$file' does not exist" >&2
	exit 2
    fi
    if eval "[ \"\${CALLMONITOR_LOADED_$lib+set}\" ]"; then
	## already loaded
	return
    else
	. "$file"
	eval "CALLMONITOR_LOADED_$lib="
    fi
}
CALLMONITOR_LOADED_system=
