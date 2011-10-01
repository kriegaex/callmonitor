if ? "$# > 0"; then
    SCRIPT=$1; shift
    case $SCRIPT in
	/*) ;;
	*) SCRIPT=$PWD/$SCRIPT ;;
    esac
    . "$SCRIPT"
else
    echo "No script given" 2>&1
fi
