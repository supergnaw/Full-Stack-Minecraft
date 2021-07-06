# Archive the current live server
tar -zcvf "/home/spigot/backups/archive/server_$(date '+%Y-%m-%d_%H-%M-%S%z(%Z)').tar.gz" "/home/spigot/backups/live/server/*"
# Remove archives older than 7 days
find "/home/spigot/backups/archive/*" -mtime +7 -exec rm {} \;
