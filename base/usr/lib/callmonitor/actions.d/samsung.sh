require recode
require http
require xml
require url

## Documentation of request format:
## http://sourceforge.net/apps/mediawiki/samygo/index.php?title=MessageBoxService_request_format

## samsung <hostname|IP>
samsung() (
    if [ $# -ne 1 ]; then
	echo "Missing host" >&2; return 1
    fi
    host=$1

    if [ -z "$TIMESTAMP" ]; then
	TIMESTAMP=$(date "+%d.%m.%y %H:%M:%S")
    fi
    OIFS=$IFS
    IFS=" "; set -- $TIMESTAMP
    calltime=$2
    IFS="."; set -- $1
    calldate="20$3-$2-$1"
    IFS=$OIFS

    samsung_call "$host" \
	--date="$calldate" --time="$calltime" \
	--to-number="$DEST_DISP" \
	--to="$(echo "$DEST_ENTRY" | latin1_utf8)" \
	--from-number="$SOURCE_DISP" \
	--from="$(echo "$SOURCE_ENTRY" | latin1_utf8)"
)

samsung_call() {
    samsung_message call "$@"
}
samsung_text() {
    samsung_message text "$@"
}

samsung_message() {
    local opt=
    opt=$(getopt -o "" -l "date:,time:,from:,from-number:,to:,to-number:" \
	-- "$@" ) || return 1
    eval "set -- $opt"
    local date= time= from= from_number= to= to_number=
    while true; do
	case $1 in
	    --date) date=$2; shift 2 ;;
	    --time) time=$2; shift 2 ;;
	    --from) from=$2; shift 2 ;;
	    --from-number) from_number=$2; shift 2 ;;
	    --to) to=$2; shift 2 ;;
	    --to-number) to_number=$2; shift 2 ;;
	    --) shift; break ;;
	esac
    done
    if [ $# -ne 2 ]; then
	echo "Wrong number of arguments" >&2; return 1
    fi
    local host=$2 type=$1 category=
    case $type in
	call) samsung_addmessage "$host" << EOF
<Category>Incoming Call</Category>
<DisplayType>Maximum</DisplayType>
$(
    samsung_time CallTime "$date" "$time"
    samsung_person Callee "$to_number" "$to"
    samsung_person Caller "$from_number" "$from"
)
EOF
	    ;;
	text) 
	    ## read body from stdin
	    samsung_addmessage "$host" << EOF
<Category>SMS</Category>
<DisplayType>Maximum</DisplayType>
$(
    samsung_time ReceiveTime "$date" "$time"
    samsung_person Receiver "$to_number" "$to"
    samsung_person Sender "$from_number" "$from"
)
<Body>$(xmlencode)</Body>
EOF
	    ;;
	*) echo "Unknown type '$type'" >&2; return 1 ;;
    esac
}

samsung_person() {
    local tag=$1 number=$2 name=$3
    echo "<$tag>
    	<Number>$(xmlencode "$number")</Number>
	<Name>$(xmlencode "$name")</Name>
    </$tag>"
}
samsung_time() {
    local tag=$1 date=$2 time=$3
    echo "<$tag>
	<Date>$(xmlencode "$date")</Date>
	<Time>$(xmlencode "$time")</Time>
    </$tag>"
}

samsung_addmessage() {
    local url_user url_auth url_host url_port
    url_parse_authority "$1"
    local msg_id=$(date +%s-$$)
    ##
    ## Wrap message (read from stdin) in SOAP and HTTP requests and send it to
    ## TV
    ##
    local soap="<?xml version='1.0' encoding='utf-8'?>
<s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'
    xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'>
<s:Body>
<u:AddMessage xmlns:u='urn:samsung.com:service:MessageBoxService:1'>
<MessageType>text/xml</MessageType>
<MessageID>$msg_id</MessageID>
<Message>$(xmlencode)</Message>
</u:AddMessage>
</s:Body>
</s:Envelope>"

    local http="POST /PMR/control/MessageBoxService HTTP/1.0$CR
Content-Type: text/xml; charset=utf-8$CR
Host: $url_host$CR
Content-Length: ${#soap}$CR
SOAPAction: \"urn:samsung.com:service:MessageBoxService:1#AddMessage\"$CR
Connection: close$CR
$CR
$soap"

    echo -n "$http" | nc -w 1 "$url_host" "${url_port:-52235}"
}
