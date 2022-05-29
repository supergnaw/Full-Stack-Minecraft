# Start Minecraft server
USER=`whoami`

if [ ! screen -ls | grep -Pq "[\d]+\.${USER}" ]; then
	SERVER_VERSION="1.18.2"
	cd "/home/${USER}/server"
	screen -dmS ${USER} java -Xmx2G -Xms2G -jar mcserver.jar nogui
fi
