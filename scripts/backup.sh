# Inform online users if server is up that live backup is about to happen
if screen -ls | screen -ls | grep -Pq "[\d]+\.spigot"; then
	screen -S spigot -X stuff "say Server will start live backup in 5 seconds for backup.^M"
	sleep 1
	screen -S spigot -X stuff "say Server will start live backup in 4 seconds for backup.^M"
    sleep 1
	screen -S spigot -X stuff "say Server will start live backup in 3 seconds for backup.^M"
    sleep 1
	screen -S spigot -X stuff "say Server will start live backup in 2 seconds for backup.^M"
    sleep 1
	screen -S spigot -X stuff "say Server will start live backup in 1 seconds.^M"
    sleep 1
	screen -S spigot -X stuff "say Server starting live backup.^M"
fi

# Copy current server to "live" directory for mapping and tar archival without i-o errors
cp -R -u /home/spigot/server /home/spigot/backups/live

# Let server users know the backup was complete
if screen -ls | screen -ls | grep -Pq "[\d]+\.spigot"; then
	screen -S spigot -X stuff "say Server live backup successful.^M"
fi
