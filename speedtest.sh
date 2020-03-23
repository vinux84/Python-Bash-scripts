#!/bin/bash 

INTSPEED=$(speedtest-cli | grep -E -- 'Download|Upload') 

DATE=$(date '+%m-%d-%Y %r')

#cat << EOF > speeds.txt

echo -e "DATE: ${DATE}\n"
echo "$INTSPEED"

