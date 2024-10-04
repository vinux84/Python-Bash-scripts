#!/bin/bash
set -e

USERNAME=$1
IP=$2 
GATEWAY=$3

function show_usage {
  echo "Error. Usage: bash bin/dns_fix.sh [Username] [Device IP] [Gateway]"
}

function execute {
  ssh -T "${USERNAME}@${IP}" << EOF
    sudo su
    cat > /etc/network/interfaces << EOL
auto lo
iface lo inet loopback
auto eth1
allow-hotplug eth1
iface eth1 inet static
address ${IP}
netmask 255.255.255.0
gateway ${GATEWAY}
dns-nameservers ${GATEWAY}
EOL
    sudo su
    cat > /etc/systemd/resolved.conf << EOL
[Resolve] 
DNS=${GATEWAY}
FallbackDNS=8.8.8.8
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
#DNSStubListener=yes
EOL
    sudo service systemd-resolved restart	
    sudo reboot
EOF
   echo "Done"
}

function manual {
    echo "Parameter $#"
    show_usage
    exit 1
}

if [ "$#" -ne 3 ]; then
    manual
fi

execute






