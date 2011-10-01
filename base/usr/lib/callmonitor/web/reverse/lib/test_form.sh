new_test_form() {
    local test=$1
    echo "
<form action='$test' method='post'>
    <table><tr>
	<td><label for='test-number'>$(lang
	    de:"Rufnummer" en:"Number"):</label>&nbsp;</td>
	<td>
	    <input type='text' name='number' id='test-number' value='$number_val'>
	</td>
    </tr></table>
    <div class='btn'><input type='submit' 
	value='$(lang de:"Nachschlagen" en:"Look up")'></div>
</form>
"
}
