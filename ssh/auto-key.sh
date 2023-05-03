#!/bin/bash
peer="peer-"$(expr $(cat lastpeer.txt | tr "-" " " | awk '{print $2}') + 1)
key=/keys/$peer/id_rsa
ip="172.19.0."$(expr $(cat last-ip.txt | tr "." " " | awk '{print $4}') + 1)
mkdir -p keys/$peer
ssh-keygen -t rsa -f keys/$peer/id_rsa -q -N ""
echo $ip > last-ip.txt
echo $peer > lastpeer.txt
echo "Created config!"