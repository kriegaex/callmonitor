ensure_file() {
    local file dir
    for file; do
	if ! touch "$file" 2> /dev/null; then
	    dir=$(dirname "$file")
	    ensure_dir "$dir" && touch "$file"
	fi
    done
}
ensure_dir() {
    local dir
    for dir; do
	[ -e "$dir" ] || mkdir -p "$dir"
    done
}

## 'read -r' that skips comments and empty lines
readx() {
    local __
    while true; do
	read -r "$@" || return $?
	eval "__=\$$1"
	case $__ in
	    \#*|"") continue ;;
	    *) return 0 ;;
	esac
    done
}
