#!/bin/sh
. /usr/lib/callmonitor/modules/recode.sh

# input
number="0123456789"
book="dasoertliche"

# processing ...
name="Märchenstündchen \\\"123\\\""

CR="$(printf '\r')"

begin_json() {
    json_state="^"
    json_indent=""
}
end_json() {
    case $json_state in
	"") echo ;;
	*) json_error ;;
    esac
}
json_pop() {
    case $json_state in
	*"$1") json_state=${json_state%?}; json_indent=${json_indent%  } ;;
	*) json_error ;;
    esac
}
json_trypop() {
    case $json_state in
	*"$1") json_state=${json_state%?} ;;
    esac
}
json_error() {
    echo "JSON error: state '$json_state': $*" >&2
}
json_nl() {
    echo
    echo -n "$json_indent"
}
json_push() {
    json_state="${json_state}$1"
    json_indent="${json_indent}  "
}
json_accept() {
    local state
    for state; do
	case $json_state in
	    *"$state") return ;;
	esac
    done
    json_error acceptable $*
}
json_sep() {
    case $json_state in
	*"o"|*"oN"|*"a") echo -n ","; json_nl ;;
	*"n") echo -n ": "; json_trypop "n" ;;
	*"{") json_state="${json_state}o" ;;
	*"{N") json_state="${json_state%N}oN" ;;
	*"[") json_state="${json_state}a" ;;
    esac
}

begin_array() {
    json_accept "^" "a" "n"
    json_sep
    echo -n "["
    json_push "["
    json_nl
}
end_array() {
    json_trypop "a";
    json_pop "["
    json_trypop "^"
    json_nl
    echo -n "]"
}
begin_object() {
    json_accept "^" "a" "n"
    json_sep
    echo -n "{"
    json_push "{"
    json_nl
}
end_object() {
    json_trypop "o";
    json_pop "{"
    json_trypop "^";
    json_nl
    echo -n "}"
}
string() {
    json_accept "[" "a" "n" "N"
    json_sep
    echo -n '"'; echo -n "$1" | latin1_json; echo -n '"'
}
number() {
    json_accept "[" "a" "n"
    json_sep
    echo -n "$1"
}
special() {
    json_accept "[" "a" "n"
    json_sep
    echo -n "$1"
}
name() {
    json_accept "{" "o"
    json_state="${json_state}N"
    string "$1"
    json_state="${json_state%N}n"
}

# output as JSON
echo "Content-Type: application/json; charset=UTF-8$CR"
echo "$CR"
begin_json;
begin_object;
    name "$number"; string "foo";
    name "name"; string "$name";
    name "bar"; number 123;
    name "oo"; begin_object;
	name "foo"; string "bar";
	name "bar"; special true;
    end_object;
    name "aa"; begin_array;
	string "foo";
	number 423.423;
    end_array
end_object;
end_json;
begin_json
begin_array
number 1
number 2
end_array
end_json
