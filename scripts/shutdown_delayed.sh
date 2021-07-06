if [ -z "$1" ]; then
	MINUTES="$1"
fi

if screen -ls | screen -ls | grep -Pq "[\d]+\.spigot"; then
	screen -S spigot -X stuff "say Server will art in 5 minutes $1^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 4 minutes $1^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 3 minutes $1^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 2 minutes $1^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 1 minute $1^M"
	sleep 30
	screen -S spigot -X stuff "say Server will restart in 30 seconds $1^M"
	sleep 20
	screen -S spigot -X stuff "say Server will shutdown in 5 seconds $1^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 4 seconds $1^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 3 seconds $1^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 2 seconds $1^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 1 second $1^M"
	sleep 1
	screen -S spigot -X stuff "stop^M"
	sleep 5
fi
