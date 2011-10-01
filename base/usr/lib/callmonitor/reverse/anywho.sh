_reverse_anywho_url() {
    local number="${1#${LKZ_PREFIX}1}"
    URL="http://www.anywho.com/qry/wp_rl?telephone=$(urlencode "$number")"
}
_reverse_anywho_request() {
    local URL=
    _reverse_anywho_url "$@"
    wget_callmonitor "$URL" -q -O -
}
_reverse_anywho_extract() {
   sed -n -e '
	: main
        \#Unable to return results\|<!-- /All_LISTINGS # {
	    '"$REVERSE_NA"'
	}
	/<!-- listing /,\#<!-- /listing\|<DIV CLASS="phone"# {
	    /<!-- Out for now /d
	    H
	}
	\#<!-- /listing \|<DIV CLASS="phone"# b cleanup
	b

	: cleanup
	g
	s#<B>#<rev:name>#
	s#</B>#</rev:name>#
	s/<BR>/, /g
	'"$REVERSE_SANITIZE"'
	'"$REVERSE_OK"'
    '
}
