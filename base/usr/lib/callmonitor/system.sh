## efficient boolean expressions with 'let': some syntactic sugar
## (busybox 1.2.1: no longer necessary; 'test' ('[') is a built-in!
__is_true() {
    let "$*"
}
alias \?=__is_true

empty() {
    [ -z "$*" ]
}

## utilities for managing "libraries"
require() {
    local lib=$1; shift
    local file=${CALLMONITOR_LIBDIR}/modules/$lib.sh
    if ? "LIB_$lib != 1"; then
	let "LIB_$lib = 1"
	. "$file" "$@"
    fi
}

support() {
    local lib=$1; shift
    local file=${CALLMONITOR_LIBDIR}/modules/$lib.sh
    [ -e "$file" ] && require "$lib"
}

## feature sets
have() {
    [ -e "${CALLMONITOR_LIBDIR}/features/$1" ]
}
