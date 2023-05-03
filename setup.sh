#!/bin/sh

#services start
wg-quick up wg0 #Peer Variable
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD  -p tcp -i wg0 --dst 172.19.0.0/16
wget https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz /tmp
tar -Jxpf s6-overlay-noarch.tar.xz
wget https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-x86_64.tar.xz /tmp
nohup tar -Jxpf s6-overlay-x86_64.tar.xz
rm -rf /tmp s6-overlay-noarch.tar.xz
rm -rf /tmp s6-overlay-x86_64.tar.xz
mkdir /tmp
chmod 777 /tmp
nohup /usr/sbin/sshd -D &

# htdocs symlink
mkdir /home/anish/htdocs #username variable
cp /var/www/html/index.html /home/anish/htdocs/
rm -rf /var/www/html
ln -s /home/anish/htdocs/ /var/www/html #username variable


#apache config file symlink
mkdir /home/anish/htconfig/
cp -rn /etc/apache2/sites-available/* /home/anish/htconfig
rm -rf /etc/apache2/sites-available
ln -s /home/anish/htconfig /etc/apache2/sites-available

# change permissions to htdocs
cd /home
chmod 775 anish #username variable
chown -R anish:anish /home/anish/htdocs #username variable
adduser www-data anish #username variable
# echo "Options +FollowSymLinks +SymLinksIfOwnerMatch" > /home/anish/htdocs/html/.htaccess #username variable
cd /home/anish/htdocs #username variable
chmod o+x *

#chaning permissions to htconfig
chown -R anish:anish /home/anish/htconfig
chown -R anish:anish /home/anish/.ssh
chown -R anish:anish /home/anish/.bashrc

#remove password
echo "anish ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2ensite" | sudo tee -a /etc/sudoers.d/anish > /dev/null
echo "anish ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2enmod" | sudo tee -a /etc/sudoers.d/anish > /dev/null
echo "anish ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dismod" | sudo tee -a /etc/sudoers.d/anish > /dev/null
echo "anish ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dissite" | sudo tee -a /etc/sudoers.d/anish > /dev/null


touch init.sh
chmod +x  init.sh
./init.sh
#code-server configuration
cd /home/anish #username variable
mkdir .config
mkdir .config/code-server
cd .config/code-server
#username variable
whoami >> id
# ip="$(ifconfig | grep 172.19 | awk '{print $2}')"
echo "bind-addr: 0.0.0.0:1111
auth: password
password: anish@321 
cert: false" > config.yaml
echo "hello" > hello.txt
service apache2 start
chown -R anish:anish /home/anish/.node-red/
npm i bcryptjs -g
# cd /home/anish/anish
#username variable
su anish <<EOF 
cd /home/anish/.node-red
whoami > user.txt
sed -i 's/^.*username:.*$/'"username: '"$(echo whoami)"',/" settings.js
sed -i 's/^.*password:.*$/'"password: '"$(node -e "console.log(require('bcryptjs').hashSync('$(echo whoami)@321', 8));")"',/" settings.js
node-red &
mkdir /home/anish/.ssh/
chown anish:anish .ssh/
chmod go-w /home/anish/
chmod 700 /home/anish/.ssh
chmod 600 /home/anish/.ssh/authorized_keys
cd /home/anish && ./init.sh
echo anish@321 | sudo -S service apache2 restart
nohup code-server
EOF