#!/bin/sh

clear 
echo "\n\n################################################################################################################
      \n\n			                       NODE CONFIGURATION
      \n\n################################################################################################################

      \n\nRemember the node must be in Recovery Mode before any configuration can happen. 
This can be done by switching the tab toward the arrow while the node is powered down, located next to the OTG port.

      \n\nNext, Plug a micro-usb from the OTG port into the Linux machine. Then power the device up using a 12v power supply. 
      \n\n"

while true; do
    read -p "Are you ready to configure the node and begin the flash process? : " conf_input
    case $conf_input in
        [Yy]* ) echo "\nContinuing to flash"; break;;
        [Nn]* ) echo "\nExiting process"; exit;;
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

LSUSB_CHECK=$(lsusb | grep 'Bus 002 Device 031: ID 0955:7c18 NVidia Corp.') 

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
	x=1
	while [ $x -le 5 ] 
	do
        	echo -n "!"
        	sleep .2
        	x=$(( $x + 1 ))
	done
else
	echo "\n\nFlash was not successful, exiting now"
	sleep 2
	exit
fi

clear
echo "\n\n###############################################################################################################
      \nPower down the node and take the node out of recovery mode
      \nUnplug the micro-usb from the OTG port
      \nPlug an ethernet cable from the Linux machine into port 1

      \n######\n\nTIP: the next part is configuring the node and assigning an IP 
while you do the next part, if you need to flash several nodes
you are able to start another 25 minute flash sequence on 
a second node while configuring the first.
      \n######

      \nLet's confirm the node works by pinging it, then assigning it a ip address\n\n"

while true; do
    read -p "Have you completed the above instructions and are you ready to change this computers ip address to ping node? : " ip_input
    case $ip_input in
        [Yy]* ) echo "\nChanging PC's ip address to the node's subnet"; break;;
        [Nn]* ) echo "\nPlease finish the above instructions to ping node and assign it a ip address";;
        * ) echo "Please answer yes or no.";;
    esac
done

sudo ifconfig wlp0s20f3 192.168.8.25 netmask 255.255.255.0      # this code just needs to change to the Eth. interface name on linux machine

IP_CHECK=$(ifconfig | grep 'inet 192.168.8.25  netmask 255.255.255.0  broadcast 192.168.8.255')  

if [ -z "$IP_CHECK" ]; then
       	sleep 2
        echo "\n\nIP address did not change"
        sleep 2
	exit
else
	sleep 2
	echo "\n\nConfiguration machine IP changed, pinging node to confirm...."
        sleep 2
fi

if ping -c 4 192.168.8.101; then                  
        sleep 2                                                
        echo -n "\nPing completed successfully!"
        x=1
        while [ $x -le 5 ] 
        do
                echo -n "!"
                sleep .2
                x=$(( $x + 1 ))
        done
else
        echo "\nPing was not successful, exiting now"
        sleep 2
        exit
fi

sudo systemctl stop NetworkManager && sudo systemctl enable NetworkManager && sudo systemctl start NetworkManager

echo "\n\nNext you will enter the production ip address so it can be configured to the Node as well as the routers ip address"


read -p "\n\nPlease put in production ip address for node : " prod_ip_node
read -p "\n\nPlease put in production ip address for node's router : " prod_ip_router

echo "\n\nChanging IP address to production IP address to node and assigning its gateway ip address"
sleep 2

ssh-copy-id -i ~/Desktop/Node_Configuration/ssh_key nvidia@192.168.8.101

bash /home/cainthus/Desktop/Node_Configuration/change_ip.sh ~/Desktop/Node_Configuration/ssh_key $prod_ip_node/24 255.255.255.0 $prod_ip_router



# Finally, validate the new IP address by changing this computer to be under the same subnet, and try pinging the new IP address:

# need to figure out how to open another terminal to ping node

sudo ifconfig wlp0s20f3 10.0.1.101 netmask 255.255.255.0      # this code just needs to change to the Eth. interface name on linux machine
							      # Also need to split up prod_ip_node, so like 10.0.x.25 (ip address) to assign pc in same subnet
IP_CHECK=$(ifconfig | grep 'inet 10.0.1.101  netmask 255.255.255.0  broadcast 192.168.8.255')

if [ -z "$IP_CHECK" ]; then
        sleep 2
        echo "\n\nIP address did not change"
        sleep 2
        exit
else
        sleep 2
        echo "\n\nLinux machine IP changed continuing to ping"
        sleep 2
fi

if ping -c 4 $prod_ip_node; then
        sleep 2
        echo -n "\nPing completed successfully!"
        x=1
        while [ $x -le 5 ] 
        do
                echo -n "!"
                sleep .2
                x=$(( $x + 1 ))
        done
else
        echo "\nPing was not successful, exiting now"
        sleep 2
        exit
fi


# ping 10.0.x.101

















