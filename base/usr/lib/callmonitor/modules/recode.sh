## requires /usr/lib/callmonitor/bin/recode

## convert latin1 to utf8
latin1_utf8() {
    $CALLMONITOR_LIBDIR/bin/recode latin1_utf8
}
## convert latin1 to JSON string (utf8) without enclosing double quotes
latin1_json() {
    $CALLMONITOR_LIBDIR/bin/recode latin1_json
}

## convert utf8 to latin1
utf8_latin1() {
    _recode '
	s/ c2 \([89ab]\)/\1/g
	s/ c3 8/c/g
	s/ c3 9/d/g
	s/ c3 a/e/g
	s/ c3 b/f/g
	: multi
	s/ [cd]. ../3f/g
	s/ e. .. ../3f/g
	s/ f\([0-7].\|[89ab]. ..\|[cd]. .. ..\) .. .. ../3f/g
	/ [c-f]/ {
	    N
	    s/\n//
	    b multi
	}
	s/ //g
	s/\(..\)/\\x\1/g
    '
}

_recode() {
    hexdump -v -e '100/1 " %02x" "\n"' |
    sed -e "$1" |
    while IFS= read -r line; do echo -ne "$line"; done
}
