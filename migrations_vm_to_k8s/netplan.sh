#!/bin/bash

if [ $(id -u) != 0 ]
then
        echo "Needs to be root!"
        exit
fi

if [ -z "$1" ]
then
        echo "You have to pass the XX of the local IP"
        exit
fi


echo "
    ens192:
      addresses:
        - 10.32.15.$1/24" >> /etc/netplan/01-netcfg.yaml


echo "Next commands, added to history:"
echo "netplan --debug try --config-file /etc/netplan/01-netcfg.yaml"
echo "netplan --debug try --config-file /etc/netplan/01-netcfg.yaml" >>  ~/.bash_history
echo "netplan apply"
echo "netplan apply"  >>  ~/.bash_history
echo "ping -c5 10.32.15.141"
echo "ping -c5 10.32.15.141"  >>  ~/.bash_history

echo "Run history -n to get them"

echo "Thank you for your service master, you are amazing !"
exit



