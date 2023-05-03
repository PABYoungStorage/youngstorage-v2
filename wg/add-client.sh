#!/bin/bash
sudo tee /etc/sudoers.d/$USER <<END
END
echo "Creating client config for: $peer"
peer="peer-"$(expr $(cat lastpeer.txt | tr "-" " " | awk '{print $2}') + 1)
mkdir -p clients/$peer
wg genkey | tee clients/$peer/$peer.priv | wg pubkey > clients/$peer/$peer.pub
wg genpsk > clients/$peer/$peer.psk
key=$(cat clients/$peer/$peer.priv)
key2=$(cat clients/$peer/$peer.pub) 
psk=$(cat clients/$peer/$peer.psk)
ip="172.19.0."$(expr $(cat last-ip.txt | tr "." " " | awk '{print $4}') + 1)
cat wg0-client.example.conf | sed -e 's/:CLIENT_IP:/'"$ip"'/' | sed -e 's|:CLIENT_KEY:|'"$key"'|' | sed -e 's|:PSK_KEY:| '"$psk"'|' > clients/$peer/$peer.conf
echo $ip > last-ip.txt
echo $peer > lastpeer.txt
echo "Created config!"
echo "Adding peer"
a="[Peer]"
b="PublicKey"
d="AllowedIPs"
e=$(cat last-ip.txt)
f="PresharedKey"
echo '' | sudo tee -a /etc/wireguard/wg0.conf
echo $a |  sudo tee -a /etc/wireguard/wg0.conf
echo $d "=" $e/32 | sudo  tee -a /etc/wireguard/wg0.conf
echo $b "=" $key2 | sudo  tee -a /etc/wireguard/wg0.conf
echo $f "=" $psk | sudo  tee -a /etc/wireguard/wg0.conf
qrencode -t png -o clients/$peer/$peer.png -r clients/$peer/$peer.conf
wg syncconf wg0 <(wg-quick strip wg0)
sudo chown cloud:cloud clients/$peer
sudo chown cloud:cloud clients/$peer/$peer.conf
sudo chown cloud:cloud clients/$peer/$peer.png
sudo wg show

