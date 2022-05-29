# Stop Minecraft server
USERNAME=`whoami`

if screen -ls | grep -Pq "[\d]+\.${WHOAMI}"; then
	screen -S ${WHOAMI} -X stuff "stop^M"
	sleep 5
fi
