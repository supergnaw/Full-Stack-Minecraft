if [ -z "$2" ]; then
	SECONDS=300
else
	SECONDS=$2
fi

if screen -ls | grep -Pq "[\d]+\.spigot"; then
	while [ $SECONDS -ge 61 ]; do
		MINUTES=$SECONDS/60
		screen -S spigot -X stuff "say Server will art in 5 minutes ${SECONDS}^M"
		SECONDS=$SECONDS-60
		sleep 1m
	done
	screen -S spigot -X stuff "say Server will art in 5 minutes ${SECONDS}^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 4 minutes ${SECONDS}^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 3 minutes ${SECONDS}^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 2 minutes ${SECONDS}^M"
	sleep 1m
	screen -S spigot -X stuff "say Server will restart in 1 minute ${SECONDS}^M"
	sleep 30
	screen -S spigot -X stuff "say Server will restart in 30 seconds ${SECONDS}^M"
	sleep 20
	screen -S spigot -X stuff "say Server will shutdown in 5 seconds ${SECONDS}^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 4 seconds ${SECONDS}^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 3 seconds ${SECONDS}^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 2 seconds ${SECONDS}^M"
	sleep 1
	screen -S spigot -X stuff "say Server will shutdown in 1 second ${SECONDS}^M"
	sleep 1
	screen -S spigot -X stuff "stop^M"
	sleep 5
fi
