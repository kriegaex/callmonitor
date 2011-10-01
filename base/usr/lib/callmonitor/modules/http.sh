require version

## carriage return & line feed
CR=$'\r'
LF=$'\n'

## output an HTTP Authorization header (Basic)
## _http_basic_auth <user> <password>
_http_basic_auth() {
    local user=$1 password=$2
    echo -n "$user:$password" | uuencode -m - |
    sed -e '1d;2s/^/Authorization: Basic /;3,$s/^/ /;s/$/'$CR'/;$d'
}

## HTTP utilities

readonly VAR_http="HTTP_PATH HTTP_VIRTUAL HTTP_AUTH"
_http_init_request() {
    local method=$1
    echo "$method $HTTP_PATH HTTP/1.0$CR"
    echo "Host: $HTTP_VIRTUAL$CR"
    echo "User-Agent: callmonitor/${CALLMONITOR_VERSION}$CR"
    ! empty "$HTTP_AUTH" && echo "$HTTP_AUTH"
}
_http_end_header() {
    echo "$CR"
}

## prepare some HTTP headers
_http_prepare() {
    if ! empty "$USERNAME$PASSWORD"; then
	HTTP_AUTH=$(_http_basic_auth "$USERNAME" "$PASSWORD")
    fi
    HTTP_VIRTUAL=${HTTP_VIRTUAL:-$HOST}
}
