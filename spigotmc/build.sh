BUILD_LOG="/var/log/spigotmc/build.log"
UPDATE_LOG="/var/log/spigotmc/update.log"
CRONTAB="/var/spool/cron/crontabs/spigotmc"

if [ `whoami` == root ]; then
	# Create log directory and associated logs
	if [ ! -d "/var/log/spigotmc" ]; then
		mkdir "/var/log/spigotmc"
		echo "$(date +"%F %T"): Installing Spigot..." | tee -a "${UPDATE_LOG}"
	else
		echo "$(date +"%F %T"): Repairing Spigot install..." | tee -a "${UPDATE_LOG}"
	fi

	# Check for spigotmc user
	if [ 0 == `getent passwd spigotmc | wc -l` ]; then
		# Add spigotmc user
		echo "$(date +"%F %T"): Creating new user account: spigotmc" | tee -a "${UPDATE_LOG}"
		useradd -m -s /bin/bash spigotmc
	fi

	# Set spigotmc user account password
	if [ ! ${1} ]; then
		read -sp "Please provide a password for the spigotmc user account:" PASSWORD < /dev/tty
		echo "spigotmc:${PASSWORD}" | chpasswd
	else
		PASSWORD=${1}
		if [ ${PASSWORD} ]; then
			echo "spigotmc:${PASSWORD}" | chpasswd
		fi
	fi

	# Get the latest BuildTools
	if [ -d "/opt/Spigot" ]; then
		echo "$(date +"%F %T"): Removing existing local directory..." | tee -a "${UPDATE_LOG}"
		rm -rf "/opt/Spigot"
	fi
	echo "$(date +"%F %T"): Fetching latest Spigot BuildTools..." | tee -a "${UPDATE_LOG}"
	mkdir "/opt/Spigot"
	cd "/opt/Spigot"

	# Build Spigot
	echo "$(date +"%F %T"): Buildig Spigot..." | tee -a "${UPDATE_LOG}"
	wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
	git config --global --unset core.autocrlf
	java -jar BuildTools.jar
	# java -jar BuildTools.jar --rev ${SERVER_VERSION}

	# Crete cron job for automatic updates
	echo "$(date +"%F %T"): Creating automatic updates cron job" | tee -a "${UPDATE_LOG}"
	if [[ -f "${CRONTAB}" ]]; then
		rm "${CRONTAB}"
	fi
	touch "${CRONTAB}"
	HOURS=$(( $RANDOM % 11 )) # Randomize time for whatever reason
	echo "10 ${HOURS}/12 * * * bash /opt/Full-Stack-Minecraft/spigotmc/build.sh" | tee -a "${CRONTAB}"

	# Permissions
	echo "$(date +"%F %T"): Updating permissions..." | tee -a "${UPDATE_LOG}"
	chown -R spigotmc:spigotmc "/opt/Spigot"
	chmod -R 755 "/opt/Spigot"
	chown -R spigotmc:spigotmc "/var/log/spigotmc"
	chmod -R 755 "/var/log/spigotmc"
	chmod 600 "${CRONTAB}"
	chown spigotmc:crontab "${CRONTAB}"

	echo "$(date +"%F %T"): Spigot install complete!" | tee -a "${UPDATE_LOG}"
else
	if [ `whoami` == "spigotmc" ]; then
		# Repository check
		if [ ! -d "/opt/Spigot" ]; then
			echo "Please run this script as root or using sudo for the initial install"
			exit
		fi

		# Check for recent updates
		cd "/opt/Spigot"
		wget -O NewBuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

		if [[ "$( sha1sum NewBuildTools.jar )" -ne "$( sha1sum BuildTools.jar )" ]]; then
			# If changes are present then rebuild
			echo "$(date +"%F %T"): changes found, updating..." | tee -a "${UPDATE_LOG}"
			rm BuildTools.jar
			mv NewBuildTools.jar BuildTools.jar
			git config --global --unset core.autocrlf
			java -jar BuildTools.jar

			# Complete!
			echo "$(date +"%F %T"): Comoplete!" | tee -a "${UPDATE_LOG}"
		else
			# No updates were found
			echo "$(date +"%F %T"): No updates found." | tee -a "${UPDATE_LOG}"
			rm NewBuildTools.jar
		fi
	else
		if [ -f "${UPDATE_LOG}" ]; then
			echo "$(date +"%F %T"): Script attempted to run under user $(whoami)" | tee -a "${UPDATE_LOG}"
		fi
		echo " "
		echo "=== Spigot ==="
		echo " "
		echo "Please run this script as root for the initial install or to repair an existing install, or as user spigotmc to check for updates."
		echo " "
	fi
fi
