#! /bin/sed -f
##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2007  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##

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
