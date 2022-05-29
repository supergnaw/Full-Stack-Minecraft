# Install LAMP
if [ `whoami` -ne root ]; then
	echo "Please run this script as root or using sudo for the initial install"
	exit
fi

while true; do
	read -sp "MySQL Database Password (at least 8 characters long):" MYSQL_DATABASE_PASS
	if [ 7 < `expr length ${MYSQL_DATABASE_PASS}` ]; then
		break
	fi
done

while true; do
	read -p "Enter username for phpMyAdmin root user:" PHPMYADMIN_ROOT

	if [ 0 -eq `getent passwd ${PHPMYADMIN_ROOT} | wc -l` ]; then
		echo "Invalid username provided. Your options are:"
		echo " "
		getent passwd | grep -P "^\w+:\w+:\d{4,}:" | cut -d ":" -f 1
		echo " "
	else
		break
	fi
done

while true; do
	read -sp "Enter password for phpMyAdmin root user (at least 8 characters long):" PHPMYADMIN_PASS
	if [ 7 < `expr length ${PHPMYADMIN_PASS}` ]; then
		break
	fi
done

# Install Apache
apt install -y apache2
systemctl enable apache2
systemctl restart apache2

# Install PHP and various modules
apt install -y php libapache2-mod-php php-mysql phpmyadmin php-mbstring php-zip php-gd php-json php-curl

# Install Database Server
apt install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl restart mariadb

# Perform secure cleanup
mysqladmin -u root password "${MYSQL_DATABASE_PASS}"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "UPDATE mysql.user SET Password=PASSWORD('${MYSQL_DATABASE_PASS}') WHERE User='root'"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"${MYSQL_DATABASE_PASS}" -e "FLUSH PRIVILEGES"

# Configure phpMyAdmin root user
mysql -u $user -p"${MYSQL_DATABASE_PASS}" -e "CREATE USER '${PHPMYADMIN_ROOT}'@'localhost' IDENTIFIED WITH caching_sha2_password BY '${PHPMYADMIN_PASS}';"
mysql -u $user -p"${MYSQL_DATABASE_PASS}" -e "ALTER USER '${PHPMYADMIN_ROOT}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${PHPMYADMIN_PASS}';"
mysql -u $user -p"${MYSQL_DATABASE_PASS}" -e "GRANT ALL PRIVILEGES ON *.* TO '${PHPMYADMIN_ROOT}'@'localhost' WITH GRANT OPTION;"

# Secure phpMyAdmin portal page
sed '/^\s*DirectoryIndex.*/a \tAllowOverride All' /etc/apache2/conf-available/phpmyadmin.conf > /etc/apache2/conf-available/phpmyadmin.conf.bak
rm /etc/apache2/conf-available/phpmyadmin.conf
mv /etc/apache2/conf-available/phpmyadmin.conf.bak /etc/apache2/conf-available/phpmyadmin.conf
echo "AuthType Basic" | tee -a "/usr/share/phpmyadmin/.htaccess"
echo "AuthName \"Restricted Files\"" | tee -a "/usr/share/phpmyadmin/.htaccess"
echo "AuthUserFile /etc/phpmyadmin/.htpasswd" | tee -a "/usr/share/phpmyadmin/.htaccess"
echo "Require valid-user" | tee -a "/usr/share/phpmyadmin/.htaccess"
echo "${PHPMYADMIN_ROOT}:$(openssl passwd -6 ${PHPMYADMIN_PASS})" >> /etc/phpmyadmin/.htpasswd
systemctl restart apache2
