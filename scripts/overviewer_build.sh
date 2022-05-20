# Check for overviewer directory
if [ ! -d "/opt/Minecraft-Overviewer" ]; then
	# Check for root permissions since we're modifying the directory structure
	if [ `whoami` != root ]; then
		echo "Please run this script as root or using sudo for the initial install"
		exit
	fi
	# Add overviewer user
	if [ 0 == `getent passwd overviewer` | wc -l` ]; then
		useradd -m -s /bin/bash overviewer
		# Generate a random base64 password based on the answer to life, the universe, and everything
		PASSWORD=`openssl rand -base64 42`
		echo "overviewer:${PASSWORD}" | chpasswd
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
	chown -R /opt/Minecraft-Overviewer overviewer:overviewer
	chmod -R 755 /opt/Minecraft-Overviewer
	# Create auto-update cron job
	SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
	touch /var/spool/cron/crontabs/overviewer
	echo "0 5 * * 1 bash ${SCRIPTPATH}/overviewer_build.sh" | tee -a /var/spool/cron/crontabs/overviewer
	chmod 600 /var/spool/cron/crontabs/overviewer
	chown overviewer:crontab /var/spool/cron/crontabs/overviewer
else
	# Make sure the script is being ran as overviewer user
	if [ $USER != "overviewer" ]; then
		echo "Please run this script as 'overviewer' user"
		exit
	fi
	# Check for repository updates
	cd /opt/Minecraft-Overviewer && git fetch
	UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
	# If updates exist, pull then rebuild
	if [ "" != "${UPDATES}"]; then
		git pull
		python3 setup.py build
	fi
fi
