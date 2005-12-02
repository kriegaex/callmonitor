# lock $file by creating a symlink $file.lock -> PID;
lock() {
	local file="$1" interval="${2:-1000000}" first=true
	# race conditions between touch and realpath still possible
	if [ ! -e "$1" ] && ! touch "$1"; then
		return 1
	fi
	file="$(lock_filename "$file")"
	local lock="$file.lock"
	if [ -e "$lock" -a "$$" = "$(realpath "$lock" 2> /dev/null)" ]; then
		# process already has lock
		return 0
	fi
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
	local file="$(lock_filename "$1")"
	local lock="$file.lock"
	if [ -e "$lock" -a "$$" = "$(realpath "$lock" 2> /dev/null)" ]; then
		rm "$lock"
	fi
}
