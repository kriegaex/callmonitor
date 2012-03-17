require uuid

## packets being created have a hyphen '-' prepended to their filename
packet_new() {
    local dir=$1 id=$2
    local date=$(date -u -Iseconds)
    if ! let "${id:+1}"; then
	id=$(uuid_new)
    fi
    local name="$id"
    local complete="$dir/-$name"
    touch "$complete" || return 1
    echo "$complete"
    return 0
}

## deliver the packet by renaming it
packet_deliver() {
    local name=$1
    local target=${name%/-*}/${name##*/-}
    mv -f "$name" "$target"
}

packet_ls() {
    local dir=$1
    ls "$dir"/[^-]*
}

## remove all but $size packets (as well as stale packets)
packet_cleanup() {
    local dir=$1 size=$2
    ls -tr "$dir"/[^-]* | tail -q -n "+${size:-15}" | xargs rm -f
    find "$dir" -maxdepth 1 -type f -name "-*" -mmin +15 | xargs rm -f
}

packet_snapshot() {
    local dir=$1 dir2=$2
    ln "$dir"/[^-]* "$dir2"/
}
