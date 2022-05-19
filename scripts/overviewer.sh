# Alert users performance may be impacted
if screen -ls | grep -Pq "[\d]+\.spigot"; then
    screen -S spigot -X stuff "say New map rendering, server may experience slower performance until it is complete.^M"
fi

# Render new map
python3 /home/spigot/overviewer/Minecraft-Overviewer/overviewer.py --config=/home/spigot/overviewer/overviewer-mini.cfg

# Inform users the new map is complete and available
if screen -ls | grep -Pq "[\d]+\.spigot"; then
    screen -S spigot -X stuff "say Map render complete! You can check it out at http://supernawesome.com/^M"
fi
