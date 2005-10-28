# Basic networking utilities

CR=$(printf '\015')

# URL encoding
urlencode() {
	echo -e $(echo -n "$*" |
	hexdump -v -e '/1 "!%02x"' |
	sed -f /proc/self/fd/9 9<<-\END )
	s/!\(2[1ade]\)/\\x\1/g
	s/!\(3[0-9]\)/\\x\1/g
	s/!\(4[1-9a-f]\)/\\x\1/g
	s/!\(5[0-9af]\)/\\x\1/g
	s/!\(6[1-9a-f]\)/\\x\1/g
	s/!\(7[0-9a]\)/\\x\1/g
	s/!/%/g
	END
}

# output an HTTP Authorization header (Basic)
# basic_auth <user> <password>
basic_auth() {
	local user="$1" password="$2"
	echo -n "$user:$password" | uuencode -m - |
	sed -e '1d;2s/^/Authorization: Basic /;3,$s/^/ /;s/$/'$CR'/;$d'
}

# default message
default_message() {
	cat <<-EOM
	Anruf an $CALLED

	von $MSISDN
	$CALLER
	EOM
}

# check if nc has the timeout option -w
if nc --help 2>&1 | grep -q -- "-w"; then
	__nc() { nc -w "$@"; }
else
	__nc() { shift; nc "$@"; }
fi

# Usage: getmsg [OPTION]... <HOST> <url-template> [<message>]...
#		 getmsg [OPTION]... -t <url-template> <host> [<message>]...
# Send a message in a simple HTTP GET request.
#
#	-t, --template=FORMAT  use this printf-style template to build the URL,
#						   all following messages are URL-encoded and filled
#						   into this template
#	-p, --port=PORT		   use a special target port (default 80)
#	-w, --timeout=SECONDS  set connect timeout (default 3)
#	-v, --virtual=VIRT	   use a different virtual host (default HOST)
#	-U, --user=USER		   user for basic authorization
#	-P, --password=PASS    password for basic authorization
getmsg() {
	local - IP= URL= TEMPLATE= VIRTUAL= USERNAME= PASSWORD= AUTH= TEMP=
	local PORT=80 TIMEOUT=3
	TEMP="$(getopt -n getmsg -o U:P:v:t:w:p: \
	-l user:,password:,virtual:,port:,template:,timeout: -- "$@")"
	if [ $? != 0 ]; then return 1; fi
	set -f; eval "set -- $TEMP"; set +f
	while true; do
	case $1 in
		-U|--user) USERNAME="$2"; shift 2 ;;
		-P|--password) PASSWORD="$2"; shift 2 ;;
		-v|--virtual) VIRTUAL="$2"; shift 2 ;;
		-t|--template) TEMPLATE="$2"; shift 2 ;;
		-w|--timeout) TIMEOUT="$2"; shift 2 ;;
		-p|--port) PORT="$2"; shift 2 ;;
		--) shift; break ;;
		*) shift ;; # should never happen
	esac
	done
	if [ $# -eq 0 ]; then echo "Missing hostname or IP" >&2; return 1; fi
	IP="$1"; shift
	if [ -z "$TEMPLATE" ]; then 
	if [ $# -eq 0 ]; then echo "Missing template" >&2; return 1; fi
	TEMPLATE="$1"; shift
	fi
	if [ $# -eq 0 ]; then set -- "$(default_message)"; fi
	VIRTUAL="${VIRTUAL:-$IP}"
	if [ -n "$USERNAME" -o -n "$PASSWORD" ]; then
	AUTH="$(basic_auth "$USERNAME" "$PASSWORD")"
	fi
	# If $1 is empty, it disappears completely in the output of "$@", which
	# shifts all messages to the left. This seems to be a bug in the busybox
	# version of ash (?). Other empty arguments work as expected.
	URL="$(set -f; IFS=/; printf "$TEMPLATE" \
	$(for arg in "$@"; do echo -n $(urlencode "$arg")/; done))"
	{
	echo "GET $URL HTTP/1.0$CR"
	echo "Host: $VIRTUAL$CR"
	[ -n "$AUTH" ] && echo "$AUTH"
	echo "$CR"
	} | __nc "$TIMEOUT" "$IP" "$PORT"
}

# Usage: rawmsg [OPTION]... <HOST> <template> [<param>]...
#		 rawmsg [OPTION]... -t <template> <host> [<param>]...
# Send a message over a plain TCP connection.
#
#	-t, --template=FORMAT  use this printf-style template to build the message,
#						   all following parameters are filled in
#	-d, --default=CODE	   default for first parameter (eval'ed later)
#	-p, --port=PORT		   use a special target port (default 80)
#	-w, --timeout=SECONDS  set connect timeout (default 3)
rawmsg() {
	local - IP= TEMPLATE= TEMP= PORT=80 TIMEOUT=3 DEFAULT=default_raw
	TEMP="$(getopt -n rawmsg -o t:w:p:d: \
	-l port:,template:,timeout:,default: -- "$@")"
	if [ $? != 0 ]; then return 1; fi
	set -f; eval "set -- $TEMP"; set +f
	while true; do
	case $1 in
		-t|--template) TEMPLATE="$2"; shift 2 ;;
		-w|--timeout) TIMEOUT="$2"; shift 2 ;;
		-p|--port) PORT="$2"; shift 2 ;;
		-d|--default) DEFAULT="$2"; shift 2 ;;
		--) shift; break ;;
		*) shift ;; # should never happen
	esac
	done
	if [ $# -eq 0 ]; then echo "Missing hostname or IP" >&2; return 1; fi
	IP="$1"; shift
	if [ -z "$TEMPLATE" ]; then 
	if [ $# -eq 0 ]; then echo "Missing template" >&2; return 1; fi
	TEMPLATE="$1"; shift
	fi
	if [ $# -eq 0 ]; then set -- "$(eval "$DEFAULT")"; fi
	# If $1 is empty, it disappears completely in the output of "$@", which
	# shifts all messages to the left. This seems to be a bug in the busybox
	# version of ash (?). Other empty arguments work as expected.
	printf "$TEMPLATE" "$@" | __nc "$TIMEOUT" "$IP" "$PORT"
}
default_raw() {
	default_message
}
