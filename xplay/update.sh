if [ `whoami` -ne fullstack || `whoami` -ne root ]; then
	echo "Please run this script as root or fullstack user"
	exit
fi

XPLAYPLUGINDIR="/opt/Cross-Play-Plugins"

if [ ! -d ${XPLAYPLUGINDIR} ]; then
	mkdir ${XPLAYPLUGINDIR}
	chown -R fullstack:fullstack ${XPLAYPLUGINDIR}
	chmod -R 755 ${XPLAYPLUGINDIR}
fi

wget -O "${XPLAYPLUGINDIR}/Geyser-Spigot.jar" "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar"
wget -O "${XPLAYPLUGINDIR}/floodgate-spigot.jar" "https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar"
