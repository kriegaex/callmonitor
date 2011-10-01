new_hash() {
    local name=$1 op
    for op in get put remove contains; do
	eval "${name}_${op}() _hash_${op} $name \"\$@\""
    done
}

_hash_get() {
    local _name=$1 _key=$2 _var=$3
    eval "$_var=\$_h_${_name}_${_key}"
}
_hash_put() {
    local _name=$1 _key=$2 _value=$3
    eval "_h_${_name}_${_key}=\$_value"
}
_hash_remove() {
    local _name=$1 _key=$2
    unset -v _h_${_name}_${_key}
}
_hash_contains() {
    local _name=$1 _key=$2
    eval "? \${_h_${_name}_${_key}+1}"
}

## new_hash a
## a_put 123 "foo"
## a_put 456 "lasijdflaisjdf"
## a_get 123 val
## echo $val
## a_get 456 val
## echo $val
## if a_contains 123; then echo yes; else echo no; fi
## a_remove 123
## a_get 123 val
## echo $val
## if a_contains 123; then echo yes; else echo no; fi
