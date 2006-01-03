sed_re_escape() {
	sed -e 's/[*\\\/.^$[]/\\&/g'
}
