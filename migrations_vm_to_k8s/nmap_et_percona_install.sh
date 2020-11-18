#!/bin/bash

if [ $(id -u) != 0 ]
then
        echo "Needs to be root!"
        exit
fi

release=$(lsb_release -sc)
echo "Release = ${release}"
url="https://repo.percona.com/apt/percona-release_latest.${release}_all.deb"
echo "URL = ${url}"
wget ${url}
dpkg -i percona-release_latest.${release}_all.deb
apt update
apt install -y percona-xtrabackup-24 nmap

echo "All is ok !"
