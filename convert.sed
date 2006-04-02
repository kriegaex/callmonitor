#! /bin/sed -f
## rough conversion of 'callmonitor/listeners' to new format (>= v0.8)

## trim whitespace
s/^[[:space:]]*//
s/[[:space:]]*$//

## preserve comments and empty lines
/^\(#.*\)\?$/ {p; d}

## keep original line for reference (unless the conversion is lossless)
/^\(NT\|\*\|E\):\|^.*mail_missed_call/ {
    h
    s/^/## /
    p
    x
}

## replace prefixes with similar events
/^NT:/ {
    s/^NT:/out:request	/
    b
}
/^\*:/ {
    s/^\*:/*:request	/
    b
}
/^E:/ {
    s/^E:/*:disconnect	/
    b
}

## no prefix
s/^/in:request	/

## simple use of mail_missed_call
s/in:request\(\([[:space:]]\+[^[:space:]]\+\)\{2\}[[:space:]]\+\)mail_missed_call\([[:space:]]\+\|$\)/in:cancel\1mailmessage\3/
