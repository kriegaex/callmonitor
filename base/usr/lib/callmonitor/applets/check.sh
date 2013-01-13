## check for errors in rules (read from stdin)

## line number
lineno=0
errors=0

rule_error() {
    let errors++
    echo "$lineno: $*"
    echo "      event:   $event"
    echo "      source:  $source"
    echo "      dest:    $dest"
    echo "      action:  $action"
}

in_r='in?'
out_r='o(ut?)?'
dir_r="($in_r|$out_r|\\*)"
req_r='r(e(q(u(e(st?)?)?)?)?)?'
can_r='c(a(n(c(el?)?)?)?)?'
con_r='c(o(n(n(e(ct?)?)?)?)?)?'
dis_r='d(i(s(c(o(n(n(e(ct?)?)?)?)?)?)?)?)?'
type_r="($req_r|$can_r|$con_r|$dis_r|\\*)"
pat_r="($dir_r:$type_r|\\*)"
spec_r="^$pat_r(,$pat_r)*\$"

check_event() {
    local e=$1
    if ! echo "$e" | egrep -q "$spec_r"; then
	rule_error "Invalid event specification"
    fi
}

check_pattern() {
    local p=$1 name=$2
    ## simple but frequent cases
    case $p in
	^|^SIP[0-9]*|^SIP[0-9]\$) return ;;
	*[^0-9^$]*|?*^*|*\$*?) ;;
	*) return ;;
    esac

    ## use egrep to check regexp syntax
    local error=$(echo | egrep -q "$p" 2>&1)
    if ! empty "$error"; then
	rule_error "${error#egrep: xregcomp: } in $name"
    fi
}

while read -r event source dest action
do
    let lineno++

    ## comment or empty line
    case $event in \#*|"") continue ;; esac

    if empty "$source"; then
	rule_error "Source pattern is missing"
    elif empty "$dest"; then
	rule_error "Destination pattern is missing"
    elif empty "$action"; then
	rule_error "Action is missing"
    fi

    check_event "$event"
    check_pattern "$source" "source pattern"
    check_pattern "$dest" "destination pattern"
done
exit $((errors > 0))
