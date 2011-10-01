xmlencode() {
    if [ $# -eq 0 ]; then
	sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g;'
    else
	case $1 in
	    *[\&\<\>]*) echo -n "$1" | xmlencode ;;
	    *) echo -n "$1" ;;
	esac
    fi
}
