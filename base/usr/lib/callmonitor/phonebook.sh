# phonebook.sh (callmonitor v0.3)

. "${CALLMONITOR_LIBDIR}/net.sh"

# resolve numbers to names and addresses (www.dasoertliche.de)
reverse_lookup() {
    local NUMBER="$(reverse_normalize "$1")"
    getmsg -w 5 www.dasoertliche.de "$NUMBER" \
	-t '/DB4Web/es/oetb2suche/home.htm?main=Antwort&s=2&kw_invers=%s' |
    sed -e '/<a class="blb" href="home.htm/!d' \
    -e 's#<br>#, #g' -e 's#<[^>]*># #g' \
    -e 's#[ 	][ 	]*# #g' -e 's#^ ##' -e 's# $##' -e 's# ,#,#'
}
# normalize phone numbers before reverse lookup; you can put your customized
# definition into /var/tmp/callmonitor.out
reverse_normalize() {
    local NUMBER="$1" OKZ=
    case $NUMBER in
	0049*) NUMBER="0${NUMBER#0049}" ;;
	0*) ;;
	*) OKZ="$(get_it CALLMONITOR_OKZ)"; NUMBER="$OKZ$NUMBER" ;; 
    esac
    echo "$NUMBER"
}
