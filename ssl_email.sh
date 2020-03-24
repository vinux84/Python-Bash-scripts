#!/bin/bash

# will check sslkeylog.log to see if it has something it

SSL_LOG=/home/katrb/sslkeylog.log

if [ -s "$SSL_LOG" ]
then
	echo "sslkeylog.log has accumulated data" | mail -s "SSL Activated" vincentb0824@gmail.com  
else
	exit 0 
fi


