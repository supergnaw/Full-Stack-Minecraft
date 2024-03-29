if [ `whoami` == "root" ]; then
	# Create log directory and associated logs
	if [ ! -d "/var/log/fullstack" ]; then
		mkdir "/var/log/fullstack"
		touch "/var/log/fullstack/update.log"
		echo "$(date +"%F %T"): Installing Full-Stack-Minecraft..." | tee -a "/var/log/fullstack/update.log"
	else
		echo "$(date +"%F %T"): Repairing Full-Stack-Minecraft install..." | tee -a "/var/log/fullstack/update.log"
	fi

	# Check for fullstack user
	if [ 0 == `getent passwd fullstack | wc -l` ]; then
		# Add fullstack user
		echo "$(date +"%F %T"): Creating new user account: fullstack" | tee -a "/var/log/fullstack/update.log"
		useradd -m -s /bin/bash fullstack
	fi

	# Set fullstack user account password
	if [ ! ${1} ]; then
		read -sp "Please provide a password for the fullstack user account:" PASSWORD < /dev/tty
		echo "fullstack:${PASSWORD}" | chpasswd
	else
		PASSWORD=${1}
		if [ ${PASSWORD} ]; then
			echo "fullstack:${PASSWORD}" | chpasswd
		fi
	fi

	# Clone the repository
	if [ -d "/opt/Full-Stack-Minecraft" ]; then
		echo "$(date +"%F %T"): Removing existing local repository..." | tee -a "/var/log/fullstack/update.log"
		rm -rf "/opt/Full-Stack-Minecraft"
	fi
	echo "$(date +"%F %T"): Cloning Full-Stack-Minecraft repository..." | tee -a "/var/log/fullstack/update.log"
	git clone "https://github.com/supergnaw/Full-Stack-Minecraft.git" "/opt/Full-Stack-Minecraft"

	# Create cron job for automatic updates
	echo "$(date +"%F %T"): Creating automatic updates cron job..." | tee -a "/var/log/fullstack/update.log"
	CRONTAB="/var/spool/cron/crontabs/fullstack"
	if [[ -f "${CRONTAB}" ]]; then
		rm "${CRONTAB}"
	fi
	touch "${CRONTAB}"
	HOURS=$(( $RANDOM % 24 )) # Randomize time for whatever reason
	MINUTES=$(( $RANDOM % 60 ))
	echo "${MINUTES} ${HOURS} * * * bash /opt/Full-Stack-Minecraft/install.sh" | tee -a "${CRONTAB}"

	# Permissions
	echo "$(date +"%F %T"): Updating permissions..." | tee -a "/var/log/fullstack/update.log"
	chown -R fullstack:fullstack "/opt/Full-Stack-Minecraft"
	chmod -R 755 "/opt/Full-Stack-Minecraft"
	chown -R fullstack:fullstack "/var/log/fullstack"
	chmod -R 755 "/var/log/fullstack"
	chmod 600 "${CRONTAB}"
	chown fullstack:crontab "${CRONTAB}"

	# Install PaperMC
	cd "/opt/Full-Stack-Minecraft"
	bash "./papermc/build.sh"

	# Install Mincraft Overviewer
	cd "/opt/Full-Stack-Minecraft"
	bash "./overviewer/build.sh"

	# Complete!
	echo "$(date +"%F %T"): Full-Stack Minecraft install complete!" | tee -a "/var/log/fullstack/update.log"
else
	if [ `whoami` == "fullstack" ]; then
		# Repository check
		if [ ! -d "/opt/Full-Stack-Minecraft" ]; then
			echo "Please run this script as root or using sudo for the initial install"
			exit
		fi

		# Check for repository updates
		cd "/opt/Full-Stack-Minecraft"
		git config core.fileMode false
		git fetch
		UPDATES=`git diff --shortstat origin/main | wc -l`
		if [[ 0 -ne ${UPDATES} ]]; then
			# If updates exist, pull them
			UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
			echo "$(date +"%F %T"): ${UPDATES} changes found, updating..." | tee -a "/var/log/fullstack/update.log"
			git reset --hard
			git pull

			# Complete!
			echo "$(date +"%F %T"): Complete!" | tee -a "/var/log/fullstack/update.log"
		else
			# No updates were found
			echo "$(date +"%F %T"): No updates found." | tee -a "/var/log/fullstack/update.log"
		fi
	else
		if [ -f "/var/log/fullstack/update.log" ]; then
			echo "$(date +"%F %T"): Script attempted to run under user $(whoami)" | tee -a "/var/log/fullstack/update.log"
		fi
		echo " "
		echo "=== Full-Stack Minecraft V1 ==="
		echo " "
		echo "Please run this script as root for the initial install or to repair an existing install, or as user fullstack to check for updates."
		echo " "
	fi
fi
