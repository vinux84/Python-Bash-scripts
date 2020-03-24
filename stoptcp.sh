#!/bin/bash

# Stop tcpdump

PID=$(/bin/ps -ef | grep tcpdump | grep -v grep | grep -v ".sh" | awk '{print $2}')

/bin/kill -9 $PID




