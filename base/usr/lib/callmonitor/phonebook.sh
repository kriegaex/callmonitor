require net

# resolve numbers to names and addresses (www.dasoertliche.de); the number is
# used as given (should be normalized beforehand)
reverse_lookup() {
	local NUMBER="$1"
	case "$NUMBER" in
		00*|[^0]*|*[^0-9]*) return;
	esac
	getmsg -w 5 www.dasoertliche.de "$NUMBER" \
	-t '/DB4Web/es/oetb2suche/home.htm?main=Antwort&s=2&kw_invers=%s' |
	sed -e '
		/<a class="blb" href="home.htm/!d
		s#<br>#, #g
		s#<[^>]*># #g
		s#[[:space:]]\+# #g
		s#^ ##
		s# $##
		s# ,#,#
	'
}
# normalize phone numbers
normalize_number() {
	local NUMBER="$1"
	case $NUMBER in
		0049*) NUMBER="0${NUMBER#0049}" ;;
		49*) if [ ${#NUMBER} -gt 10 ]; then NUMBER="0${NUMBER#49}"; fi ;;
	esac
	case $NUMBER in
		[1-9]*) NUMBER="${CALLMONITOR_OKZ}${NUMBER}" ;; 
	esac
	echo "$NUMBER"
}
