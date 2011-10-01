## Execute a single action (such as dboxmessage or anything else that can
## appear in the "Listeners")

require callmonitor_config
require usage
## requires /usr/lib/callmonitor/usage/callaction.sh
__configure

## Additional modules may be loaded via -M<module>
while true; do
    case $1 in
	-M*) require "${1#-M}"; shift ;;
	--help|-*) usage >&2; exit ;;
	*) break ;;
    esac
done
"$@"
