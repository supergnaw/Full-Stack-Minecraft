if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo to remove Overviewer"
    exit
fi

userdel overviewer
rm -rf /var/spool/cron/crontabs/overviewer
rm -rf /var/log/overviewer
rm -rf /opt/Minecraft-Overviewer
