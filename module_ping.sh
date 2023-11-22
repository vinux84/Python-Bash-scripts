#!/bin/bash

clear

declare -A devices

devices[ROUTER]=254
devices[SWITCH1]=252
devices[SWITCH2]=253
devices[WEBRELAY]=240
devices[NODE]=101

echo " "

read -p "Please enter IP subnet for Module: " subnet

echo " "

while true; do
    read -p "Is there two managed switches in this module? [yes/no]: " switches
    case $switches in
	[Yy]* ) echo " "; break;;
        [Nn]* ) unset devices[Switch2]; break;;
        * ) echo "\nPlease answer yes or no";;
    esac
done

for device in "${!devices[@]}";
do
	printf "\n\nPinging $device now...\n\n"
	if ping -c 2 10.0.$subnet.${devices[$device]}; then
                printf "\n\n$device is up and connected..\n"
		devices_up+=("$device")
        else
                printf "\n\n$device is down and not connected..\n"
		devices_down+=("$device")
        fi
done

echo " "
echo "********************"
echo "Device Status Report"
echo "********************"
echo " "
echo "Devices that are up: ${devices_up[@]}"
echo " "
echo "Devices that are down: ${devices_down[@]}"

unset devices_up
unset devices_down 

echo " "

exit




