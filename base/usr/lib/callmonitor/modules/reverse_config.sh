require hash
## requires /usr/lib/callmonitor/reverse/provider.cfg

_reverse_init() {
    local type prov countries site label lkz entry cfg=

    ## validation
    for entry in $CALLMONITOR_REVERSE_PROVIDER; do
	lkz=${entry%:*}
	prov=${entry#*:}
	if grep -q "^R[^	]*	$prov	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	    cfg="$cfg $entry"
	fi
    done

    ## add missing default entries
    while readx type prov countries site label; do
	case $type in R*) ;; *) continue ;; esac
	case $countries in
	   *\!*)
		lkz=${countries%!*}
		lkz=${lkz##*,}
		if [ "$lkz" = "*" ]; then
		    lkz=other
		fi
		case " $cfg" in
		    *" $lkz:"*) ;;
		    *) cfg="$cfg $lkz:$prov" ;;
		esac
		;;
	esac
    done < "$CALLMONITOR_REVERSE_CFG"

    ## this config covers every known country and refers only to valid
    ## providers
    REVERSE_PROVIDER=$cfg

    ## validate (and possibly correct) area provider
    if ! grep -q "^A[^	]*	$CALLMONITOR_AREA_PROVIDER	" "$CALLMONITOR_REVERSE_CFG" > /dev/null; then
	AREA_PROVIDER=
    else
	AREA_PROVIDER=$CALLMONITOR_AREA_PROVIDER
    fi

    new_hash REVERSE_PROVIDER
    for entry in $REVERSE_PROVIDER; do
	REVERSE_PROVIDER_put "${entry%:*}" "${entry#*:}"
    done

    unset -f _reverse_init
}
_reverse_init
