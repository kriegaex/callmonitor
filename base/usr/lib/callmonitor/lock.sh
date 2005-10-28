# lock $file by creating a symlink $file.lock -> PID
lock() {
	local file="$(realpath "$1")" interval="${2:-1000000}" first=1
	local lock="$file.lock"
	while ! ln -s $$ "$lock" 2> /dev/null; do
	if [ $first -eq 1 ]; then 
		first=0
		echo "Waiting for exclusive lock on $file" 1>&2
	fi
	usleep $interval
	done
}

unlock() {
	local file="$(realpath "$1")"
	local lock="$file.lock"
	rm "$lock"
}
