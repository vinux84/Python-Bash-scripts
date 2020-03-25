#!/bin/bash

line_array=($(speedtest-cli | grep -E -- 'Download|Upload' | awk '{print $2}'))

echo ${line_array[1]} 



