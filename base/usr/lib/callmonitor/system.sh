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

## nc with NC_110_COMPAT behaves differently with null input (hangs), but has
## -z for port scanning
if LC_ALL=C busybox nc -z 2>&1 | egrep -q "(illegal|invalid) option -- z"; then
    nc_scan() {
	busybox nc "$@" < /dev/null > /dev/null 2>&1
    }
else
    nc_scan() {
	busybox nc -z "$@" < /dev/null > /dev/null 2>&1
    }
fi
