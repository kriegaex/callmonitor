sed_re_escape() {
	sed -e 's/[*\\\/.^$[]/\\&/g'
}
grep_re_escape() { sed_re_escape; }
