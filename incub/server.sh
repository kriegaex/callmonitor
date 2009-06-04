#!/bin/sh

run=/home/buehmann/var/run/myserver
input="$run/input"

case $1 in
    client) 
	output="$run/o.$$"
	cleanup() { rm -f "$output"; }
	trap cleanup 0
	mkfifo "$output"
	IFS="|"
	echo "$$|$*" > "$input"
	cat "$output"
	exit
    ;;
esac


mkdir -p "$run"
mkfifo "$input"

process() {
    local output=$1; shift
    work "$@" > "$run/o.$output"
}

work() {
    local arg
    for arg; do
	echo -n "|$arg"
    done
    echo "|"
}

echo Listening on $input
cleanup() { rm -f "$input"; kill "${pid:-$$}"; }
trap cleanup 0
sleep 20000d > "$input" & pid=$!
while IFS="|" read _1 _2 _3 _4 _5 _6 rest; do
    echo $_1
    { process "$_1" "$_2" "$_3" "$_4" "$_5" "$_6" & } & wait $!
done < "$input"
