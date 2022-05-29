# Start Minecraft server
if [ ! screen -ls | grep -Pq "[\d]+\.$(whoami)_server" ]; then
	cd "/home/$(whoami)/server"
	screen -dmS "$(whoami)_server" java -Xmx2G -Xms2G -jar mcserver.jar nogui
fi
