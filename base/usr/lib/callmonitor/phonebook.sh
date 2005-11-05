. "${CALLMONITOR_CFG:=/mod/etc/default.callmonitor/system.cfg}"
. "${CALLMONITOR_LIBDIR}/net.sh"

# resolve numbers to names and addresses (www.dasoertliche.de); the number is
# used as given (should be normalized beforehand)
reverse_lookup() {
	local NUMBER="$1"
	case "$NUMBER" in
		00*|[1-9]*) return;
	esac
	getmsg -w 5 www.dasoertliche.de "$NUMBER" \
	-t '/DB4Web/es/oetb2suche/home.htm?main=Antwort&s=2&kw_invers=%s' |
	sed -e '/<a class="blb" href="home.htm/!d' \
	-e 's#<br>#, #g' -e 's#<[^>]*># #g' \
	-e 's#[ 	][ 	]*# #g' -e 's#^ ##' -e 's# $##' -e 's# ,#,#'
}
# normalize phone numbers
normalize_number() {
	local NUMBER="$1"
	case $NUMBER in
		0049*) NUMBER="0${NUMBER#0049}" ;;
		0*) ;;
		*) NUMBER="${CALLMONITOR_OKZ}${NUMBER}" ;; 
	esac
	echo "$NUMBER"
}
