#!/bin/bash

# Start the collection to process output later
tcpdump -i enp0s3 -n -v 'icmp[icmptype] == icmp-echoreply' | tee icmpdump & pid=$!

zmap --probe-module=icmp_echoscan --max-targets=10000 -P 10
echo "Waiting for packets to finish coming in"
sleep 10

# Kills the tcpdump we started earlier so we can process the file it creates
kill "$pid"

# Now on to post-processing
# Using awk to print out the IP address of the reply and the IP-ID of the response
awk '/reply/ {print $1} /IP/ {print $7,$8}' icmpdump > output

# xargs gets everything on the same line
xargs -a output -n2 -d'\n' > almost
# Using awk again to flip the line to IP IP-ID
awk -F',' '{print $2, $1}' almost > results
#Sorting so all of the responses are together in the file
sort results -o results
echo "Results file created"
