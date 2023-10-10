# this requires that you have a linux machine and have set up multiple interfaces for the default subnet of the node, and the new subnet of the intended IP address for node. and a micro usb plugged into the configuration
# Linux Machine

#!/bin/sh

clear 
echo "\n\n################################################################################################################
      \n\n			                       NODE CONFIGURATION
      \n\n################################################################################################################

      \n\nThe node must be in recovery mode before any configurations can happen. 
This can be done by switching the tab in the same direction of the arrow while the node is powered down, it is located next to the OTG port.

      \n\nNext, Plug in a micro-usb in the OTG port on the node. Then power the device up using a 12v power supply. 
      \n\n"

while true; do
    read -p "Are you ready to configure the node and begin the flash process? : " conf_input
    case $conf_input in
        [Yy]* ) echo "\nContinuing to flash"; break;;
        [Nn]* ) echo "\nExiting process"; exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -n "\n\nChecking Node."
x=1
while [ $x -le 20 ] 
do
        echo -n "."
        sleep .2
        x=$(( $x + 1 ))
done

LSUSB_CHECK=$(lsusb | grep 'NVIDIA') 

if [ -z "$LSUSB_CHECK" ]; then
	sleep 2
	echo "\n\nNode not recognized for some reason, exiting now"
	sleep 2
	exit
else
	sleep 2
	echo "\n\nNode recognized, flashing node now, This should take about 25 mins"
	sleep 2
fi 	

if cd ~/Desktop/Node_Configuration/Firmware/v0.1/Linux_for_Tegra && sudo ./flash.sh -r -k APP jetson-tx2 mmcblk0p1 ; then                 
	sleep 2						       
	echo -n "\n\nFlash completed successfully!"
	sleep 4
else
	echo "\n\nFlash was not successful, exiting now"
	sleep 2
	exit
fi

clear

echo "\n\n###############################################################################################################
      \nPower down the node and take the node out of recovery mode
      \nUnplug the micro-usb from the OTG port
      \nPlug an ethernet cable from the configuration into port 1
      \n######\n\nThe next part is configuring the node and assigning a IP to it.
While you do the next part, if you need to flash another node
you can start another 25 minute flash sequence on
a second node while configuring the first.
      \n######
      \nLet's confirm the node works by pinging it, then assigning it a ip address\n\n"
      
while true; do
    read -p "Have you completed the above instructions and are you ready to go forward with configuring the node? : " ip_input
    case $ip_input in
        [Yy]* ) echo "\nConfiguring the Node"; break;;
        [Nn]* ) echo "\nPlease finish the above instructions to continue the configuration process on the node";;
        * ) echo "Please answer yes or no.";;
    esac
done

if ping -c 4 192.168.8.101; then
        sleep 2
        echo -n "\nNode is up, default ping completed successfully and can continue the process"
        x=1
        while [ $x -le 5 ]
        do
                echo -n "!"
                sleep .2
                x=$(( $x + 1 ))
        done
else
        echo "\nDefault ping was not successful, check your configuration machine interfaces. exiting now"
        sleep 2
        exit
fi

if echo "nvidia" | sudo -S ssh-copy-id -i ~/Desktop/Node_Configuration/ssh_key nvidia@192.168.8.101 ; then      # I added "sudo -S" to the command. have not tried -  the password pipe didn't work. had to manually put in pw. maybe a expect block would work better.
        sleep 2
        echo -n "\nSSH key sent to node.."
        sleep 4
else
        echo "\nSSH key was not sent to node, something is wrong. exiting now"
        sleep 2
        exit 1
fi

echo "\nNext you will enter the production ip address and gateway ip address to the node"

read -p "\nPlease put in production ip address for node : " prod_ip_node
read -p "\nPlease put in production ip address for node's gateway : " prod_ip_router

echo "\nChanging default ip address to production ip address and assigning its gateway ip address"
sleep 2

if bash /home/cainthus/Desktop/Node_Configuration/change_ip.sh ~/Desktop/Node_Configuration/ssh_key $prod_ip_node/24 255.255.255.0 $prod_ip_router ; then
        sleep 2
        echo -n "\nNode IP change was not successful"
        sleep 4
        exit 1
else
        echo "\nNode IP change was successful"
        sleep 2
fi

echo "\nWaiting for node to reboot..."
sleep 45
echo "\nConfirming node ip address has changed..."

if ping -c 4 $prod_ip_node; then
        sleep 2
        echo -n "\nSuccessfully pinged new ip address of node"
        x=1
        while [ $x -le 5 ]
        do
                echo -n "!"
                sleep .2
                x=$(( $x + 1 ))
        done
else
        echo "\nPing was not successful, node IP didn't change or something is wrong with your interfaces. exiting now"
        sleep 2
        exit 1
fi

echo "\nFormatting SSD now, this will take a few minutes...."
sleep 2
# below will ask for a yes, as its the first time sshing in.
ssh -i ~/Desktop/Node_Configuration/ssh_key nvidia@$prod_ip_node "bash -s" << EOF
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

echo "\nSending boot settings to node..."
sleep 2

scp -i ~/Desktop/Node_Configuration/ssh_key /home/cainthus/Desktop/Node_Configuration/boot_settings nvidia@$prod_ip_node:~/

echo "\nBacking up boot settings and rebooting..."
sleep 2

ssh -i ~/Desktop/Node_Configuration/ssh_key nvidia@$prod_ip_node "bash -s" << EOF
	sudo cp /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.backup
 	sudo mv boot_settings /boot/extlinux/extlinux.conf
  	sudo reboot
EOF

echo "\nThat's it. ALL DONE!!"

exit 0


















