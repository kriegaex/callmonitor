##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2006  Andreas Bühmann <buehmann@users.berlios.de>
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

mail_subject() {
    case $EVENT in
	in:cancel) echo "Verpasst: Anruf${SOURCE:+" von $SOURCE"}" ;;
	*) echo "Anruf${SOURCE:+" von $SOURCE"}" ;;
    esac
}
mail_body() {
    default_mailmessage | sed -e "s/\$/$CR/"
}
default_mailmessage() { 
    default_message
    echo
    echo "$TIMESTAMP [$EVENT]"
}
    
mailmessage() {
    mail_body | mail send -i - -s "$(mail_subject)" "$@"
}
## put a call to 'mail process' into your crontab in order to process mails
## that could not yet be delivered
