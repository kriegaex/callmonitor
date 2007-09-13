#<
    cat <<END
Usage:	phonebook [option]... command [argument]...
	phonebook {get|exists|remove} 053712931
	phonebook put 0357937829 "John Smith"
	phonebook list [all]
	phonebook init # prepare SIP to name mapping
	phonebook tidy # tidy up phonebook (sort)
	phonebook flush # flush temporary caches
Options:
    --local  suppress reverse lookup
    --debug  enable extra debugging output
    --help   show this help and exit
END
#>
