sudo iptables --flush INPUT
sudo iptables -A INPUT -p tcp --dport 25565 -j ACCEPT -m comment --comment "Minecraft Java"
sudo iptables -A INPUT -p udp --dport 19132 -j ACCEPT -m comment --comment "Minecraft Bedrock"
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "HTTP"
sudo iptables -A INPUT -p tcp --dport 22366 -j ACCEPT -m comment --comment "SSH"
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS"

