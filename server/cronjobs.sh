USER=`whoami`

# Hourly live backups
echo "0 */1 * * * bash /opt/Full-Stack-Minecraft/backup/live.sh" | tee -a /var/spool/cron/crontabs/${USER}

# Map rendering half-past every 6 hours
echo "30 */6 * * * bash /opt/Full-Stack-Minecraft/overviewer/render.sh ${USER} $PATH_TO_CONFIG" | tee -a /var/spool/cron/crontabs/${USER}

# Live backup archival every 6 hours
echo "0 */6 * * * bash /opt/Full-Stack-Minecraft/backup/archive.sh" | tee -a /var/spool/cron/crontabs/${USER}

# Restart server if not running
echo "*/5 * * * * bash /opt/Full-Stack-Minecraft/server/start.sh" | tee -a /var/spool/cron/crontabs/${USER}

# Permissions
chmod 600 /var/spool/cron/crontabs/${USER}
chown ${USER}:crontab /var/spool/cron/crontabs/${USER}
