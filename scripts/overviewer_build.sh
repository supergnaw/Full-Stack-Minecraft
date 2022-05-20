# Check for overviewer directory
if [ ! -d "/opt/Minecraft-Overviewer" ]; then
	# Check for root permissions since we're modifying the directory structure
	if [ `whoami` != root ]; then
		echo "Please run this script as root or using sudo for the initial install"
		exit
	fi
	# Check for overviewer user
	if [ 0 == `getent passwd overviewer | wc -l` ]; then
		# Check if overviewer password was provided
		if [ ! ${1} ]; then
			echo "Please provide a password for the user: overviewer"
			exit
		fi
		# Add overviewer user
		useradd -m -s /bin/bash overviewer
		# Set overviewer password
		echo "overviewer:${1}" | chpasswd
	fi
	# Install/update packages
	apt-get install -y software-properties-common
	apt-get update -y
	apt-get install -y python3-pil python3-dev python3-numpy
	# Clone the repository
	git clone https://github.com/overviewer/Minecraft-Overviewer.git /opt/Minecraft-Overviewer
	cd /opt/Minecraft-Overviewer
	# Build overviewer
	python3 setup.py build
	chown -R overviewer:overviewer /opt/Minecraft-Overviewer
	chmod -R 755 /opt/Minecraft-Overviewer
	# Create auto-update cron job
	SCRIPTPATH=`cd -- "$( dirname "$0" )" >/dev/null 2>&1 ; pwd -P`
	touch /var/spool/cron/crontabs/overviewer
	echo "0 5 * * 1 bash ${SCRIPTPATH}/overviewer_build.sh" | tee -a /var/spool/cron/crontabs/overviewer
	echo "0/1 * * * * date | tee -a /var/log/overviewer/test.txt" | tee -a /var/spool/cron/crontabs/overviewer
	chmod 600 /var/spool/cron/crontabs/overviewer
	chown overviewer:crontab /var/spool/cron/crontabs/overviewer
	# Create log directory and associated logs
	if [ ! -d "/var/log/overviewer" ]; then
		mkdir /var/log/overviewer
	fi
	touch /var/log/overviewer/test.txt
	touch /var/log/overviewer/update.log
	touch /var/log/overviewer/rebuild.log
	chown -R overviewer:overviewer /var/log/overviewer
	chmod -R 755 /var/log/overviewer
else
	# Make sure the script is being ran as overviewer user
	if [ $USER != "overviewer" ]; then
		echo "Please run this script as 'overviewer' user"
		echo "$(date +"%F %T"): Please run this script as 'overviewer' user" | tee -a /var/log/overviewer/update.log
		exit
	fi
	echo "$(date +"%F %T"): Update check..." | tee -a /var/log/overviewer/update.log
	# Check for repository updates
	cd /opt/Minecraft-Overviewer && git fetch
	UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
	if [ "" != "${UPDATES}"]; then
		# If updates exist, pull then rebuild
		echo "$(date +"%F %T"): ${UPDATES} found, rebuilding..." | tee -a /var/log/overviewer/update.log
		git pull
		python3 /opt/Minecraft-Overviewer/setup.py build | tee -a /var/log/overviewer/rebuild.log
		echo "$(date +"%F %T"): Rebuild complete!" | tee -a /var/log/overviewer/update.log
	else
		# No updates were found
		echo "$(date +"%F %T"): No updates found." | tee -a /var/log/overviewer/update.log
	fi
fi
