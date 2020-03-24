#!/bin/bash 

INTSPEED=$(speedtest-cli | grep -E -- 'Download|Upload') 

DATE=$(date '+%m-%d-%Y %r')

#cat << EOF > speeds.txt

echo -e "DATE: ${DATE}\n"
echo "$INTSPEED"

if [[ ${INTSPEED} -lt 50 ]]
then 
	echo "You internet speed is slow"

elif [[ ${INTSPEEDJ} -gt 75 ]]
then
	echo "You have good speed" 
else
	echo "You have ok speed"
fi

	 
