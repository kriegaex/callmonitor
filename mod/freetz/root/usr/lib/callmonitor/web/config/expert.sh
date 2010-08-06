require cgi
require version

check "$CALLMONITOR_EXPERT" yes:expert
echo "
    <p style='margin-left: 1em;'>
    <input type='hidden' name='expert' value='no'>
    <input type='checkbox' name='expert' value='yes'$expert_chk id='ex1'>
    <label for='ex1'>$(lang 
	de:"Expertenansicht aktivieren" 
	en:"Enable expert's view"
    )</label>
    <span style='float: right; margin-right: 1em;'><a target='_blank' href='$CALLMONITOR_FORUM_URL'>Version
    $CALLMONITOR_VERSION</a></span>
    </p>
"
