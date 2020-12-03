#!/bin/bash

if [ $(id -u) != 0 ]
then
        echo "Needs to be root!"
        exit
fi

# stop services
echo "#### Stopping nginx";
service nginx stop
#service nginx status | grep "Active"
systemctl is-active nginx.service

echo "#### Stopping sendMail";
service sendMail stop
#service sendMail status | grep "Active"
systemctl is-active sendMail.service

echo "#### Stopping sendMailGroup";
service sendMailGroup stop
#service sendMailGroup status | grep "Active"
systemctl is-active sendMailGroup.service

# unregister from startup
systemctl disable nginx.service
systemctl is-enabled nginx.service

#systemctl disable sendMail.service
#systemctl is-enabled sendMail.service

#systemctl disable sendMailGroup.service
#systemctl is-enabled sendMailGroup.service

# empty crontab
echo "#### Jamespot user crontab:"
sudo -u jamespot crontab -l
echo "#### Emptying Jamespot user crontab ..."
sudo -u jamespot crontab -r
echo "#### Jamespot user crontab after:"
sudo -u jamespot crontab -l

# ufw setup ipv4 redirect
echo "#### Allow UFW to FORWARD by default"
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

# https://www.cyberciti.biz/faq/how-to-configure-ufw-to-forward-port-80443-to-internal-server-hosted-on-lan/
# replace also the COMMIT in the comment: # don't delete the 'COMMIT' line or these rules won't be processed
echo "#### Change UFW prerouting rules"
#sed -i 's/COMMIT//' /etc/ufw/before.rules
echo "*nat
:PREROUTING ACCEPT [0:0]
# forward vm IP port 80 to 54.38.100.208:80
# forward vm IP  port 443 to 54.38.100.208:443
-A PREROUTING -p tcp --dport 80 -j  DNAT --to-destination 54.38.100.208:80
-A PREROUTING -p tcp --dport 443 -j  DNAT --to-destination 54.38.100.208:443
# setup routing
-A POSTROUTING -d 54.38.100.208 -j MASQUERADE
COMMIT" >> /etc/ufw/before.rules


echo "#### Configure sysctl to allow ipV4 forward"
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
# I think the ufw conf override the sysctl, but just in case
sed -i 's/#net/ipv4/ip_forward=1/net/ipv4/ip_forward=1/' /etc/ufw/sysctl.conf

echo "#### Read the sysctl file"
sysctl -p

echo "#### UFW Reload"
ufw reload
echo "#### UFW status"
ufw status verbose

echo "#### IPtables rules"
iptables -t nat -L -n -v

cat <<EOF

 ▄▄▄██▀▀▀▄▄▄       ███▄ ▄███▓▓█████   ██████  ██▓███   ▒█████  ▄▄▄█████▓
   ▒██  ▒████▄    ▓██▒▀█▀ ██▒▓█   ▀ ▒██    ▒ ▓██░  ██▒▒██▒  ██▒▓  ██▒ ▓▒
   ░██  ▒██  ▀█▄  ▓██    ▓██░▒███   ░ ▓██▄   ▓██░ ██▓▒▒██░  ██▒▒ ▓██░ ▒░
▓██▄██▓ ░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄   ▒   ██▒▒██▄█▓▒ ▒▒██   ██░░ ▓██▓ ░
 ▓███▒   ▓█   ▓██▒▒██▒   ░██▒░▒████▒▒██████▒▒▒██▒ ░  ░░ ████▓▒░  ▒██▒ ░
 ▒▓▒▒░   ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░▒▓▒░ ░  ░░ ▒░▒░▒░   ▒ ░░
 ▒ ░▒░    ▒   ▒▒ ░░  ░      ░ ░ ░  ░░ ░▒  ░ ░░▒ ░       ░ ▒ ▒░     ░
 ░ ░ ░    ░   ▒   ░      ░      ░   ░  ░  ░  ░░       ░ ░ ░ ▒    ░
 ░   ░        ░  ░       ░      ░  ░      ░               ░ ░

 ██▓███   ▒█████   █     █░▓█████  ██▀███
▓██░  ██▒▒██▒  ██▒▓█░ █ ░█░▓█   ▀ ▓██ ▒ ██▒
▓██░ ██▓▒▒██░  ██▒▒█░ █ ░█ ▒███   ▓██ ░▄█ ▒
▒██▄█▓▒ ▒▒██   ██░░█░ █ ░█ ▒▓█  ▄ ▒██▀▀█▄
▒██▒ ░  ░░ ████▓▒░░░██▒██▓ ░▒████▒░██▓ ▒██▒
▒▓▒░ ░  ░░ ▒░▒░▒░ ░ ▓░▒ ▒  ░░ ▒░ ░░ ▒▓ ░▒▓░
░▒ ░       ░ ▒ ▒░   ▒ ░ ░   ░ ░  ░  ░▒ ░ ▒░
░░       ░ ░ ░ ▒    ░   ░     ░     ░░   ░
             ░ ░      ░       ░  ░   ░

EOF
cat << "EOF"
       _,.
     ,` -.)
    '( _/'-\\-.
   /,|`--._,-^|            ,
   \_| |`-._/||          ,'|
     |  `-, / |         /  /
     |     || |        /  /
      `r-._||/   __   /  /
  __,-<_     )`-/  `./  /
 '  \   `---'   \   /  /
     |           |./  /
     /           //  /
 \_/' \         |/  /
  |    |   _,^-'/  /
  |    , ``  (\/  /_
   \,.->._    \X-=/^
   (  /   `-._//^`
    `Y-.____(__}
     |     {__)
           ()`
EOF

echo "Thank you for your service master, you are amazing !"
exit
