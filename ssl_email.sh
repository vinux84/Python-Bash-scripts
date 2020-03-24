#!/bin/bash

# will check sslkeylog.log to see if it has something it

SSL_LOG=/home/name/sslkeylog.log

if [ -s "$SSL_LOG" ]
then
	echo "sslkeylog.log has accumulated data" | mail -s "SSL Activated" some@email.com   
else
	exit 0 
fi


