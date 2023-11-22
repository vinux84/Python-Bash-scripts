#!/bin/sh

# Requirements: The configuration machine needs to have 2 interfaces active, one for the default IP address and another for the node production IP addresss. 

pingcheck () {
        if ping -c 4 $1; then
                sleep 2
                echo -n "\nNode is onine..\n"
        else
                echo "\nNode isn't online, node IP didn't save configuraion settings or something is wrong with your interfaces.\n"
                while true; do
		    read -p "Check Node/Config machine IP's. Press yes when IP has been fixed to ping again, no to abort. [yes/no]: " conf_input
    		    case $conf_input in
        		[Yy]* ) pingcheck $1;;
       	 		[Nn]* ) echo "\nExiting\n"; exit 1;;
        		* ) echo "\nPlease answer yes or no";;
    		    esac
		done
        fi
}





clear

echo "\n\n################################################################################################################
      \n\n			                       NODE CONFIGURATION
      \n\n################################################################################################################
      \n\nThe node must be in recovery mode before any configurations can happen.
This can be done by switching the tab in the same direction of the arrow 
while the node is powered down, it is located next to the OTG port.
      \n\nNext, Plug in a micro-usb in the OTG port on the node and the other side to the configuration machine. 
Then power the device up using a 12v power supply.
      \n\n"

while true; do
    read -p "Are you ready to configure the node and begin the flash process? [yes/no]: " conf_input
    case $conf_input in
        [Yy]* ) echo "\n"; break;;
        [Nn]* ) echo "\nExiting Configuration"; exit 1;;
        * ) echo "\nPlease answer yes or no";;
    esac
done

echo -n "\nChecking node"

x=1
while [ $x -le 20 ]
do
        echo -n "."
        sleep .2
        x=$(( $x + 1 ))
done

LSUSB_CHECK=$(lsusb | grep -w 'NVIDIA')

if [ -z "$LSUSB_CHECK" ]; then
	sleep 2
	echo "\n\nNode not recognized for some reason, check your OTG connection. Exiting now."
	exit 1
else
	sleep 2
	echo "\n\nNode recognized. Flashing node now, This should take about 25 mins.\n"
	sleep 2
fi

if cd ~/Desktop/Node_Configuration/Firmware/v0.1/Linux_for_Tegra && echo cainthus | sudo -S ./flash.sh -r -k APP jetson-tx2 mmcblk0p1 ; then
	sleep 2						      
	echo "\n\nFlash completed successfully!"
	sleep 4
else
	echo "\n\nFlash was not successful, exiting now."
	exit 1
fi

clear

echo "\n\n###############################################################################################################
      \nFlash completed. Power down the node and take it out of recovery mode.
      \nUnplug the micro-usb from the OTG port.
      \nPlug an ethernet cable from the configuration machine into the RJ-45 port 1 of node.
      \nPower back up the node and wait for connection lights to come on the RJ-45 port.
      \n#################################################################################################################
      \n\nThe next part is configuring the node and assigning a IP to it.
While you do the next part, if you need to flash another node
you can start another 25 minute flash sequence on
a second node while configuring the first.\n
      \n#################################################################################################################i\n\n"

while true; do
    read -p "Have you completed the above instructions and are you ready to go forward with configuring the node? [yes/no]: " ip_input
    case $ip_input in
        [Yy]* ) echo "\n"; break;;
        [Nn]* ) echo "\nPlease finish the above instructions to continue the configuration process on the node\n";;
        * ) echo "\nPlease answer yes or no";;
    esac
done

echo "\nContinuing to configure the node, confirming node is online by pinging it.\n"

pingcheck 192.168.8.101

echo "\nSending SSH key..\n"

if sshpass -p 'nvidia' ssh-copy-id -i ~/Desktop/Node_Configuration/ssh_key nvidia@192.168.8.101 ; then
        sleep 2
        echo "\nSSH key sent to node.\n"
        sleep 4
else
        echo "\nSSH key was not sent to node, something is wrong, exiting now.\n"
        exit 1
fi

read -p "Please enter in production IP address for node [10.0.x.101]: " prod_ip_node
echo ""
read -p "Please enter in production IP address for node's gateway [10.0.x.254]: " prod_ip_router

echo "\nChanging default IP address to production IP and gateway IP address.\n"
sleep 2

if bash /home/cainthus/Desktop/Node_Configuration/change_ip.sh ~/Desktop/Node_Configuration/ssh_key $prod_ip_node/24 255.255.255.0 $prod_ip_router ; then
        sleep 2
        echo "\nNode IP change was not successful, exiting now."
        exit 1
else
        echo "\nNode IP change was successful."
        sleep 2
fi

echo "\nWaiting for node to reboot..."

sleep 45

echo "\nConfirming node IP address has changed.\n"

pingcheck $prod_ip_node

sleep 2

echo "\n\nFormatting SSD now, this will take about 5 minutes....\n"

sleep 2

ssh -T -o StrictHostKeyChecking=accept-new -i ~/Desktop/Node_Configuration/ssh_key nvidia@$prod_ip_node << EOF
        sudo wipefs -a /dev/sda
        sudo parted /dev/sda mklabel gpt
        sudo parted /dev/sda mkpart primary ext4 0% 100%
        sudo mkfs.ext4 /dev/sda1
        sudo mount /dev/sda1 /mnt
        sudo su
        cp -ax / /mnt && sync
        exit
        sudo cp /boot/Image /boot/Image.backup
EOF

echo "\nFormatting SSD complete."
echo "\nSending boot settings to node.\n"

sleep 2

scp -i ~/Desktop/Node_Configuration/ssh_key /home/cainthus/Desktop/Node_Configuration/boot_settings nvidia@$prod_ip_node:~/

echo "\nBacking up boot settings and restarting node.\n"

sleep 2

ssh -T -i ~/Desktop/Node_Configuration/ssh_key nvidia@$prod_ip_node << EOF
        sudo cp /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.backup
        sudo mv boot_settings /boot/extlinux/extlinux.conf
	sudo reboot 
EOF

echo "\nWaiting for node to reboot..."

sleep 45

echo "\nConfirming node is back up...\n"

pingcheck $prod_ip_node

echo -n "\nNODE CONFIGURATION IS COMPLETE" 
x=1
while [ $x -le 10 ]
do
	echo -n "!"
        sleep .2
        x=$(( $x + 1 ))
done


echo "\n\nIt can be powered down now."

exit

