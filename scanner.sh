#!/bin/bash

# Start the collection to process output later
tcpdump -i enp0s3 -n -v 'icmp[icmptype] == icmp-echoreply' | tee icmpdump & pid=$!

zmap --probe-module=icmp_echoscan --bandwidth=10M --max-targets=10 -P 10 -w target_list -f saddr,ipid
sleep 10

# Kills the tcpdump we started earlier so we can process the file it creates
kill "$pid"

# Now on to post-processing
# Using awk to print out the IP address of the reply and the IP-ID of the response
awk '/reply/ {print $1} /IP/ {print $7,$8}' icmpdump > output
xargs -a output -n2 -d'\n' > almost
awk -F',' '{print $2, $1}' almost > results
sort results -o results
echo "Results file created"
