. /usr/lib/libmodcgi.sh

html_encode() {
    sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g'
}

pre() {
    echo -n "<pre>"
    html_encode # stdin
    echo "</pre>"
}
