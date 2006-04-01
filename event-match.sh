match() {
    local event=$1 spec=$2 dir= type= IFS=,
    for pattern in $spec; do
	case $pattern in
	    ""|*:*:*)
		;;
	    *:*) 
		dir="${pattern%:*}"
		type="${pattern#*:}"
		case $event in $dir*:$type*) return 0;; esac
		;;
	    *) 
		case $event in $pattern*:*) return 0;; esac
		case $event in *:$pattern*) return 0;; esac
		;;
	esac
    done
    return 1
}

testcase() {
    echo -n "$1 $2"
    if match "$1" "$2"; then
	echo " MATCH!"
    else
	echo
    fi
}

for dir in in out; do
    for type in request cancel connect disconnect; do
	event=$dir:$type
	for pattern in "in:request" "out:cancel" ":connect" "connect" "in:*" "in" "i:d" "o:c" "*" "req,o:con"; do
	    testcase "$event" "$pattern"
	done
    done
done
