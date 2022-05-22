SERVER_VERSION=1.18

# Check for overviewer directory
if [ `whoami` == root ]; then
	# Create log files
	if [ ! -d "/var/log/overviewer" ]; then
		mkdir "/var/log/overviewer"
		touch "/var/log/overviewer/update.log"
		touch "/var/log/overviewer/build.log"
		echo "$(date +"%F %T"): Installing Minecraft-Overviewer..." | tee -a "/var/log/overviewer/update.log"
	else
		echo "$(date +"%F %T"): Repairing Minecraft-Overviewer install..." | tee -a "/var/log/overviewer/update.log"
	fi

	# Check for overviewer user
	if [ 0 == `getent passwd overviewer | wc -l` ]; then
		# Add overviewer user
		echo "$(date +"%F %T"): Creating new user account: overviewer" | tee -a "/var/log/overviewer/update.log"
		useradd -m -s /bin/bash overviewer
	fi

	# Set overviewer user account password
	if [ ! ${1} ]; then
		read -sp "Please provide a password for the overviewer user account:" PASSWORD
	else
		PASSWORD=${1}
	fi
	echo "overviewer:${PASSWORD}" | chpasswd

	# Install/update packages
	echo "$(date +"%F %T"): Updating python and packages..." | tee -a "/var/log/overviewer/update.log"
	apt-get install -y software-properties-common
	apt-get update -y
	apt-get install -y python3-pil python3-dev python3-numpy

	# Clone the repository
	echo "$(date +"%F %T"): Cloning Minecraft-Overviewer repository..." | tee -a "/var/log/overviewer/update.log"
	mkdir "/opt/Minecraft-Overviewer"
	cd "/opt/Minecraft-Overviewer"
	git clone "https://github.com/overviewer/Minecraft-Overviewer.git" "/opt/Minecraft-Overviewer"
	wget -O "/opt/Minecraft-Overviewer/textures/${SERVER_VERSION}.jar" "https://overviewer.org/textures/${SERVER_VERSION}"

	# Build overviewer
	cd "/opt/Minecraft-Overviewer"
	echo "$(date +"%F %T"): Building overviewer..." | tee -a "/var/log/overviewer/update.log"
	python3 setup.py build | tee -a "/varlog/overviewer/build.log"

	# Create cron job for automatic updates
	echo "$(date +"%F %T"): Creating automatic updates cron job..." | tee -a "/var/log/overviewer/update.log"
	CRONTAB=/var/spool/cron/crontabs/overviewer
	if [[ -f "${CRONTAB}" ]]; then
		rm "${CRONTAB}"
	fi
	touch "${CRONTAB}"
	echo "* * * * * bash /build.sh" | tee -a "${CRONTAB}"

	# Set permissions
	echo "$(date +"%F %T"): Updating permissions" | tee -a "/var/log/overviewer/update.log"
	chown -R overviewer:overviewer "/var/log/overviewer"
	chmod -R 755 "/var/log/overviewer"
	chown -R overviewer:overviewer "/opt/Minecraft-Overviewer"
	chmod -R 755 "/opt/Minecraft-Overviewer"
	chmod 600 "/var/spool/cron/crontabs/overviewer"
	chown overviewer:crontab "/var/spool/cron/crontabs/overviewer"

	# Complete!
	echo "$(date +"%F %T"): Complete!" | tee -a "/var/log/overviewer/update.log"
	exit
else
	# Make sure the script is being ran as overviewer user
	if [ `whoami` == "overviewer" ]; then
		# Repository check
		if [ -d "/opt/Minecraft-Overviewer" ]; then
			echo "Please run this script as root or using sudo for the initial install"
			exit
		fi

		# Check for repository updates
		cd "/opt/Minecraft-Overviewer"
		git config core.fileMode false
		git fetch
		UPDATES=`git diff --shortstat origin/main | wc -l`
		if [[ 0 -ne ${UPDATES} ]]; then
			# If updates exist, pull them
			UPDATES=`git diff --shortstat origin/main | cut -d " " -f 2`
			echo "$(date +"%F %T"): ${UPDATES} changes found, updating..." | tee -a "/var/log/overviewer/update.log"
			git pull

			# Rebuild
			echo "$(date +"%F %T"): Rebuilding from new updates..." | tee -a "/var/log/overviewer/update.log"
			python3 /opt/Minecraft-Overviewer/setup.py build | tee -a "/var/log/overviewer/build.log"

			# Complete!
			echo "$(date +"%F %T"): Complete!" | tee -a "/var/log/overviewer/update.log"
		else
			# No updates were found
			echo "$(date +"%F %T"): No updates found." | tee -a "/var/log/overviewer/update.log"
		fi
	else
		if [ -f "/var/log/overviewer/update.log" ]; then
			echo "$(date +"%F %T"): Script attempted to run under user $(whoami)" | tee -a "/var/log/overviewer/update.log"
		fi
		echo " "
		echo "=== Minecraft-Overviewer Automatic Updater ==="
		echo " "
		echo "Please run this script as 'overviewer' user"
		echo " "
	fi
fi

exit
