require util
dump_var() {
    local var
    for var; do
	echo -n "$var="
	eval "sh_escape \"\$$var\""
	echo
    done
}
dump() {
    dump_var "$@"
    echo "___ $*"
}
dump2() {
    ( export "$@"; sh -c "readonly $*; readonly -p $*") |
	sed -e "/^readonly [^=]*='\"'\"/! s/^readonly //"
    echo "___ $*"
}
