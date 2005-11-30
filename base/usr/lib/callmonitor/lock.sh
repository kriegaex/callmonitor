# lock $file by creating a symlink $file.lock -> PID;
lock() {
	local file="$1" interval="${2:-1000000}" first=true
	# race conditions between touch and realpath still possible
	if [ ! -e "$1" ] && ! touch "$1"; then
		return 1
	fi
	file="$(realpath "$file")"
	local lock="$file.lock"
	while ! ln -s $$ "$lock" 2> /dev/null; do
		if $first; then 
			first=false
			echo "Waiting for exclusive lock on $file" 1>&2
		fi
		usleep $interval
	done
	return 0
}

unlock() {
	local file="$(realpath "$1")"
	local lock="$file.lock"
	rm "$lock"
}
