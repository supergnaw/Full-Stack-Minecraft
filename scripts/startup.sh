if ! screen -ls | grep -Pq "[\d]+\.spigot"; then
	cd /home/spigotmc/server
	screen -dmS spigot java -Xmx2G -Xms2G -jar /home/spigot/server/spigot-1.20.2.jar nogui
fi
