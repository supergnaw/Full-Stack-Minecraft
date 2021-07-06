# Inform server users a restart is pending
if screen -ls | screen -ls | grep -Pq "[\d]+\.spigot"; then
	bash /home/spigot/scripts/shutdown_now.sh "for server rollback to most recent backup. This may take a few minutes to complete and restart the server."
fi

# Copy backup directory to live directory
cp -R -u /home/spigot/backups/live /home/spigot/server

# Restart the server
bash /home/spigot/scripts/startup.sh
