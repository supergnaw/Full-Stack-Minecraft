if screen -ls | screen -ls | grep -Pq "[\d]+\.spigot"; then
	screen -S spigot -X stuff "say Server is shutting down in 5 seconds $1^M"
	sleep 5
	screen -S spigot -X stuff "stop^M"
	sleep 5
fi
