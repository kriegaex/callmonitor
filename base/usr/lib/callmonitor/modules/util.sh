sed_re_escape() {
    case $1 in
	*[*\\\/.^$[]*) echo -n "$1" | sed -e 's/[*\\\/.^$[]/\\&/g' ;;
	*) echo -n "$1" ;;
    esac
}
grep_re_escape() { sed_re_escape "$@"; }
sh_escape() {
    echo "'${1//'/'\''}'"
}
