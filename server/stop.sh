# Stop Minecraft server
if [ screen -ls | grep -Pq "[\d]+\.$(whoami)_server" ]; then
	screen -S "$(whoami)_server" -X stuff "stop^M"
	sleep 5
fi
