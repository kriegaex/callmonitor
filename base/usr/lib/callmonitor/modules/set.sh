## maintain a set of space-separated words
set_add() {
    local name=$1 set elem; shift
    eval "set=\$$name"
    for elem; do
	case " $set " in
	    *" $elem "*) ;;
	    *) set="${set:+$set }$elem"
	esac		
    done
    eval "$name=\$set"
}
