require format
require tel

## default message (multi-line)
default_message() {
    local cols=${1:-10000} lines=${2:-10000} type=$3  # '':text, 1:html
    
    local call="$(lang de:"Anruf" en:"Call")"
    local from="$(lang de:"von" en:"from")" to="$(lang de:"an" en:"to")"

    local here here_entry here_dir there there_entry there_dir
    local p1 p2 br a1 a2 __
    case $EVENT in
	in:*)
	    there_dir=$from there=$SOURCE_DISP there_entry=$SOURCE_ENTRY
	    here_dir=$to here=$DEST_DISP here_entry=$DEST_ENTRY
	    ;;
	*)
	    here_dir=$from here=$SOURCE_DISP here_entry=$SOURCE_ENTRY
	    there_dir=$to there=$DEST_DISP there_entry=$DEST_ENTRY
	    ;;
    esac
    
    if ? 'type == 1'; then
	p1='<p>'
	p2='</p>\n'
	br='<br>'
	if [ -n "$there" ]; then
	    normalize_address "$there"
	    case "$__" in
		*@*) __="sip:$__" ;;
		*) __="tel:$__" ;;
	    esac
	    a1="<a href=$__>"
	    a2='</a>'
	fi
    fi

    echo -n "$p1"
    if ! empty "$here" && ? "lines > 1"; then
	echo "$call $here_dir ${here_entry:-$here}$br"
    elif ? "lines == 1"; then
	echo -n "$call "
    else
	echo "$call$br"
    fi
    if ! empty "$there"; then
	if ? "lines >= 3"; then
	    echo "$there_dir $a1$there$a2$br"
	    wrap "$cols" "$there_entry" $type
	else
	    echo "$there_dir $a1${there_entry:-$there}" |
		cut -c "1-$(($cols+${#a1}))" | tr -d '\n'
	    echo "$a2"
	fi
    fi
    echo -ne "$p2"
}

## one-liner
default_short_message() {
    default_message ${1:-50} 1
}
default_raw() {
    default_message
}


## wrap text (line length <= max)
wrap() {
    local max=${1:-10000} text=$2 type=$3
    local len=${#text}
    if ? "len == 0"; then
	return
    elif ? "len <= max"; then
	echo "$text"
    else
	local a=1
	while ? "a <= len"; do
	    expr substr "$text" $a $max
	    let a+=max
	    ? 'type == 1' && ? "a <= len" && echo '<br>'
	done
    fi
}
