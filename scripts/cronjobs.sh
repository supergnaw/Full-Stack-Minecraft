# #write out current crontab
# crontab -l > tmpcron.txt
# #echo new cron into cron file
# echo "00 09 * * 1-5 echo hello" >> tmpcron.txt
# #install new cron file
# crontab tmpcron.txt
# rm tmpcron.txt
#
# # (crontab -l | grep 'some_user python /mount/share/script.py') || { crontab -l; '*/1 * * * * some_user python /mount/share/script.py'; } | crontab -
#

touch /var/spool/cron/spigot
echo 0 */1 * * * bash /home/spigot/scripts/backup.sh > /var/spool/cron/spigot
echo 0 */4 * * * bash /home/spigot/scripts/overviewer.sh >> /var/spool/cron/spigot
echo 0 */8 * * * bash /home/spigot/scripts/archive.sh >> /var/spool/cron/spigot
echo 10,30,50 */1 * * * bash /home/spigot/scripts/startup.sh >> /var/spool/cron/spigot
echo 0 8 * * * bash /home/spigot/scripts/update.sh >> /var/spool/cron/spigot
