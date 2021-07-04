# Start new spigot instance if not exists
if ! screen -ls | grep -Pq "[\d]+\.spigot"; then
	cd /home/spigot/server
	screen -dmS spigot java -Xmx2G -Xms2G -jar /home/spigot/server/spigot-1.17.jar nogui
fi
