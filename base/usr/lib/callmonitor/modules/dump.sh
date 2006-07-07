dump() {
    for var; do
	echo -n "$var='"
	eval "echo -n \"\$$var\"" | sed -e "s/'/'\\\\''/g"
	echo "'"
    done
    echo "___ $*"
}
