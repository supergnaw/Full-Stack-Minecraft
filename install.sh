### PRIVILEGE CHECK ###
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

### VARAIBLES ###
read -p "User spigot password:" SPIGOT_USR_PASS
read -p "MySQL Database Password:" MYSQL_DATABASE_PASS
# read -p "Old SSH Port:" SHH_PORT_OLD
SHH_PORT_OLD=22
read -p "New SSH Port:" SSH_PORT_NEW
#read -p "Minecraft server version:" SERVER_VERSION
SERVER_VERSION=1.17
read -p "Web domain for server (without www.):" WEB_DOMAIN

# Add user for server
useradd spigot
# echo spigot:${SPIGOT_USR_PASS} | chpasswd

# Install Java
add-apt-repository ppa:linuxuprising/java
apt update
apt install -y oracle-java16-installer
add-apt-repository --remove ppa:linuxuprising/java
apt-get remove oracle-java16-installer

# Clone Repository
cd /home/spigot
git clone https://github.com/supergnaw/Full-Stack-Minecraft

# BuildTools
mkdir -p /home/spigot/buildtools
wget -O /home/spigot/BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
git config --global --unset core.autocrlf
cd /home/spigot/buildtools
java -jar BuildTools.jar --rev ${SERVER_VERSION}

# Server Directory
mkdir -p /home/spigot/server/plugins
cp /home/spigot/buildtools/spigot-${SERVER_VERSION}.jar /home/spigot/server
touch /home/spigot/server/eula.txt
echo eula=true > /home/spigot/server/eula.txt
wget -O /home/spigot/server/plugins/Geyser-Spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
wget -O /home/spigot/server/plugins/floodgate-spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar

# Scripts directory
mkdir -p /home/spigot/scripts

# Backup direcctories
mkdir -p /home/spigot/backups/live

# Overviewer
mkdir -p /home/spigot/overviewer/output
cd /home/spigot/overviewer
echo "deb https://overviewer.org/debian ./" >> /etc/apt/sources.list
wget -O - https://overviewer.org/debian/overviewer.gpg.asc | apt-key add -
apt-get update
apt-get install minecraft-overviewer
# /var/www/${WEB_DOMAIN}/public_html

# Cron Jobs
apt install -y cron
systemctl enable cron
systemctl restart cron
bash /home/spigot/scripts/cronjobs.sh

# Web Server
apt install -y apache2
systemctl enable apache2
touch /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "<VirtualHost *:80>" > /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    ServerName ${WEB_DOMAIN}" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    ServerAlias www.${WEB_DOMAIN}" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    ServerAdmin webmaster@${WEB_DOMAIN}" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    DocumentRoot /var/www/${WEB_DOMAIN}/public_html" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf

echo "    <Directory /var/www/${WEB_DOMAIN}/public_html>" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "        Options -Indexes +FollowSymLinks" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "        AllowOverride All" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    </Directory>" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf

echo "    ErrorLog ${APACHE_LOG_DIR}/${WEB_DOMAIN}-error.log" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "    CustomLog ${APACHE_LOG_DIR}/${WEB_DOMAIN}-access.log combined" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/${WEB_DOMAIN}.conf
mkdir -p /var/www/${WEB_DOMAIN}/public_html
ln -s /home/spigot/overviewer/output /var/www/${WEB_DOMAIN}/public_html/map
systemctl restart apache2
# systemctl reload apache2 # use to reload configs without dropping connections

# MySQL Database
apt install -y mariadb-server
systemctl enable mariadb
systemctl restart mariadb
mysqladmin -u root password "${MYSQL_DATABASE_PASS}"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "UPDATE mysql.user SET Password=PASSWORD('${MYSQL_DATABASE_PASS}') WHERE User='root'"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "FLUSH PRIVILEGES"

# SSH
cd /home/spigot
apt install -y openssh-server
sed "s/#Port 22/Port ${SSH_PORT_NEW}/gIm" /etc/ssh/sshd_config
systemctl restart sshd
mkdir -p /home/spigot/.ssh
touch /home/spigot/.ssh/authorized_keys
ssh-keygen -t rsa -f /home/spigot/.ssh/id_rsa
cat /home/spigot/.ssh/id_rsa.pub >> /home/spigot/.ssh/authorized_keys
chmod 600 /home/spigot/.ssh/authorized_keys
chmod 700 /home/spigot/.ssh

# Ownership
chown -R spigot:spigot /home/spigot/

# Firewall Rules
iptables --flush INPUT
iptables --flush FORWARD
iptables --flush OUTPUT
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT -m comment --comment "Minecraft Java"
iptables -A INPUT -p udp --dport 19132 -j ACCEPT -m comment --comment "Minecraft Bedrock"
iptables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "HTTP"
iptables -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
iptables -A INPUT -p tcp --dport ${SSH_PORT_NEW} -j ACCEPT -m comment --comment "SSH"
iptables -A INPUT -p tcp --dport 53 -j ACCEPT -m comment --comment "DNS"
iptables -A INPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
service iptables save

# Firewall Rules IPv6
ip6tables --flush INPUT
ip6tables --flush FORWARD
ip6tables --flush OUTPUT
ip6tables -A INPUT -p tcp --dport 25565 -j ACCEPT -m comment --comment "Minecraft Java"
ip6tables -A INPUT -p udp --dport 19132 -j ACCEPT -m comment --comment "Minecraft Bedrock"
ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "HTTP"
ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
ip6tables -A INPUT -p tcp --dport ${SSH_PORT_NEW} -j ACCEPT -m comment --comment "SSH"
ip6tables -A INPUT -p tcp --dport 53 -j ACCEPT -m comment --comment "DNS"
ip6tables -A INPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS"
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT
service ip6tables save
