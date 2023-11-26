# Variable
REVISION="1.20.2"

# Notify server of new download
bash /home/spigot/scripts/shutdown_now.sh

# Create a new server jar (typically released daily)
cd /home/spigot/buildtools
wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
git config --global --unset core.autocrlf
java -jar BuildTools.jar --rev ${REVISION}

# Update and restart the server
cp /home/spigot/buildtools/spigot-${REVISION}.jar /home/spigot/server/spigot-${REVISION}.jar
bash /home/spigot/scripts/startup.sh
