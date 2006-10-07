#<
    cat <<'EOH'
Usage: rawmsg [OPTION]... <host[:port]> <template> [<param>]...
       rawmsg [OPTION]... -t <template> <host[:port]> [<param>]...
Send a message over a plain TCP connection.

  -t, --template=FORMAT  use this printf-style template to build the message,
			 all following parameters are filled in
  -T TYPE                type of message (use default_TYPE, etc.)
  -p, --port=PORT	 use a special target port (default 80)
  -w, --timeout=SECONDS  set connect timeout (default 3)
      --help		 show this help
EOH
#>
