#!/bin/bash 

INTSPEED=($(speedtest-cli | grep -E -- 'Download|Upload' | awk '{print $2}' | awk -F '.' '{print $1}')) 

DATE=$(date '+%m-%d-%Y %r')

#to put into a file : cat << EOF > speeds.txt

echo -e "DATE: ${DATE}\n"

if [[ ${INTSPEED[0]} -ge 100 ]]
then 
	echo "You internet speed is fast"

elif [[ ${INTSPEED[0]} -lt 100 ]]
then
	echo "You have good speed" 
else
	echo "Your internet is not working"
fi

	 
