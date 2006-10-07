#<
    cat <<'EOH'
Usage:	getmsg [OPTION]... <authority> <part-url-template> [<message>]...
	getmsg [OPTION]... -t <part-url-template> <authority> [<message>]...
	getmsg [OPTION]... <full-url-template> [<message>]...
Send a message in a simple HTTP GET request.

  -t, --template=FORMAT  use this printf-style template to build the URL,
			 all following messages are URL-encoded and filled
			 into this template
  -T TYPE                type of message (use default_TYPE, encode_TYPE, etc.)
  -p, --port=PORT	 use a special target port (default 80)
  -w, --timeout=SECONDS  set connect timeout (default 3)
  -v, --virtual=VIRT	 use a different virtual host (default HOST)
  -U, --user=USER	 user for basic authorization
  -P, --password=PASS	 password for basic authorization
      --help		 show this help

  <full-url-template>    http://<authority><partial-url-template>
  <part-url-template>    e.g., /path/to/resource?query=string&message=%s
  <authority>            [user[:password]@]host[:port]
EOH
#>
