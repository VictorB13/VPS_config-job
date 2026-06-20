#!/bin/bash

#Check if the script runs with root priviliges
if [ "$EUID" -ne 0 ]; then 
    echo "You must run the script as root (sudo)..."
    exit 1
fi

echo "====== Starting the weekly maintenance job ======"
date 
echo "-------------------------------------------------"

#Disk usage state before cache clenup
echo "Disk Usage Status (before cache cleanups):"
df -h 

#Clean package manager cache"
echo "Cleaning apt cache...."
apt-get clean && apt-get autoremove -y

#Clear logs older than 7 days
echo "Clearing logs older than 7 days...."
journalctl --vacuum-time=7d

#Cleaning temporary files older than 3 days
echo "Cleaning temporary file older than 3 days in /tmp...."
find /tmp -type f -atime +3 -delete

#Free up memory cache
echo "Dropping Memory Caches...."
sync #writing all the data from the cache to the disk for avoid memory loss while cleaning the cache
echo 3 > /proc/sys/vm/drop_caches #writing number 3 into "drop_caches" is clearing the cache
echo "Memory Cache Cleared"

#Disk usage state after the cache clenup
echo "Disk Usage Status (after cache cleanups):"
df -h 

echo "====== Server Maintenance Job Completed Successfully ======" 