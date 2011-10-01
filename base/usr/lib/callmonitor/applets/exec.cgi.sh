require cgi
require if_jfritz_status

eval "$(modcgi jfritz exec)"
cgi_begin callmonitor

case $EXEC_JFRITZ in
    on)
	_j_enable &&
	echo "$(lang 
	    de:"CallMonitor-Schnittstelle eingeschaltet."
	    en:"CallMonitor interface enabled."
	)"
	;;
    off)
	_j_disable &&
	echo "$(lang 
	    de:"CallMonitor-Schnittstelle ausgeschaltet."
	    en:"CallMonitor interface disabled."
	)"
	;;
esac | html

config_button
cgi_end
