#!/bin/sh
# Example: ./rev.sh dasoertliche +49465182810
[ -z "$APPLET" ] && exec /usr/lib/callmonitor/controller "$0" "$@"

require reverse

prov=$1
number=$2

_reverse_require_provider $prov
_reverse_${prov}_request "$number" > response
_reverse_${prov}_extract < response
