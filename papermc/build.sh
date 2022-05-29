BUILD_LOG="/var/log/papermc/build.log"
UPDATE_LOG="/var/log/papermc/update.log"
CRONTAB="/var/spool/cron/crontabs/papermc"

if [ `whoami` == root ]; then
	# Create log directory and associated logs
	if [ ! -d "/var/log/papermc" ]; then
		mkdir "/var/log/papermc"
		echo "$(date +"%F %T"): Installing PaperMC..." | tee -a "${UPDATE_LOG}"
	else
		echo "$(date +"%F %T"): Repairing PaperMC install..." | tee -a "${UPDATE_LOG}"
	fi

	# Check for papermc user
	if [ 0 == `getent passwd papermc | wc -l` ]; then
		# Add papermc user
		echo "$(date +"%F %T"): Creating new user account: papermc" | tee -a "${UPDATE_LOG}"
		useradd -m -s /bin/bash papermc
	fi

	# Set papermc user account password
	if [ ! ${1} ]; then
		read -sp "Please provide a password for the papermc user account:" PASSWORD < /dev/tty
		echo "papermc:${PASSWORD}" | chpasswd
	else
		PASSWORD=${1}
		if [ ${PASSWORD} ]; then
			echo "papermc:${PASSWORD}" | chpasswd
		fi
	fi

	# Clone the repository
	if [ -d "/opt/PaperMC" ]; then
		echo "$(date +"%F %T"): Removing existing local repository..." | tee -a "${UPDATE_LOG}"
		rm -rf "/opt/PaperMC"
	fi
	echo "$(date +"%F %T"): Cloning PaperMC repository..." | tee -a "${UPDATE_LOG}"
	git clone "https://github.com/PaperMC/Paper.git"

	# Build PaperMC
	echo "$(date +"%F %T"): Buildig PaperMC..." | tee -a "${UPDATE_LOG}"
	bash ./gradlew applyPatches | tee -a "${BUILD_LOG}"
	bash ./gradlew createReobfBundlerJar | tee -a "${BUILD_LOG}"

	# Crete cron job for automatic updates
	echo "$(date +"%F %T"): Creating automatic updates cron job" | tee -a "${UPDATE_LOG}"
	if [[ -f "${CRONTAB}" ]]; then
		rm "${CRONTAB}"
	fi
	touch "${CRONTAB}"
	echo "10 */6 * * * bash /opt/Full-Stack-Minecraft/papermc/build.sh" | tee -a "${CRONTAB}"

	# Permissions
	echo "$(date +"%F %T"): Updating permissions..." | tee -a "${UPDATE_LOG}"
	chown -R papermc:papermc "/opt/PaperMC"
	chmod -R 755 "/opt/PaperMC"
	chown -R papermc:papermc "/var/log/papermc"
	chmod -R 755 "/var/log/papermc"
	chmod 600 "${CRONTAB}"
	chown papermc:crontab "${CRONTAB}"

	echo "$(date +"%F %T"): PaperMC install complete!" | tee -a "${UPDATE_LOG}"
else
	if [ `whoami` == "papermc" ]; then
		# Repository check
		if [ ! -d "/opt/PaperMC" ]; then
			echo "Please run this script as root or using sudo for the initial install"
			exit
		fi

		# Check for repository updates
		cd "/opt/PaperMC"
		git config core.fileMode false
		git fetch
		UPDATES=`git diff --shortstat origin/main | wc -l`
		if [[ 0 -ne ${UPDATES} ]]; then
			# If updates exist, pull them
			UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
			echo "$(date +"%F %T"): ${UPDATES} changes found, updating..." | tee -a "${UPDATE_LOG}"
			git pull

			# Rebuild
			bash ./gradlew applyPatches | tee -a "${BUILD_LOG}"
			bash ./gradlew createReobfBundlerJar | tee -a "${BUILD_LOG}"

			# Complete!
			echo "$(date +"%F %T"): Comoplete!" | tee -a "${UPDATE_LOG}"
		else
			# No updates were found
			echo "$(date +"%F %T"): No updates found." | tee -a "${UPDATE_LOG}"
		fi
	else
		if [ -f "${UPDATE_LOG}" ]; then
			echo "$(date +"%F %T"): Script attempted to run under user $(whoami)" | tee -a "${UPDATE_LOG}"
		fi
		echo " "
		echo "=== PaperMC ==="
		echo " "
		echo "Please run this script as root for the initial install or to repair an existing install, or as user papermc to check for updates."
		echo " "
	fi
fi
