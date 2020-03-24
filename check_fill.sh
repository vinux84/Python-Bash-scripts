#!/bin/bash

# will check sslkeylog.log to see if it has something it

SSL_LOG=/home/vin/suf1

if [ -s "$SSL_LOG" ]
then
        echo "sslkeylog.log has accumulated data"
else
        exit 0
fi

