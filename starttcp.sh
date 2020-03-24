#!/bin/bash

# Start TCPdump and store dated file tcp_filter dir  

DATE=$(date '+%m-%d-%Y_%H:%M:%S')

SAVE_AS_FILE=tcpdump_$DATE.pcap

/usr/sbin/tcpdump -i any -s0 -w /home/name/tcp_filter/$SAVE_AS_FILE







