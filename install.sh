if [ `whoami` == "root" ]; then
    # Check for fullstack user
    if [ 0 == `getent passwd fullstack | wc -l` ]; then
        # Check if fullstack user password was provided
        if [ ! ${1} ]; then
            echo "Please provide a password for new user account: fullstack"
            exit
        else
            # Add fullstack user
            useradd -m -s /bin/bash fullstack

            # Set fullstack user password
            echo "fullstack:${1}" | chpasswd
        fi
    fi

    # Clone the repository
    if [ ! -d "/opt/Full-Stack-Minecraft" ]; then
        git clone https://github.com/supergnaw/Full-Stack-Minecraft.git /opt/Full-Stack-Minecraft
    else
        cd "/opt/Full-Stack-Minecraft"
        git fetch
        UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
        [[ $UPDATES =~ '([1-9]+|[1-9][0-9]+)' ]]
        if [ $UPDATES == $BASH_REMACH[1] ]; then
            git pull
        else
            echo ""
        fi
    fi
	# Create log directory and associated logs
	if [ ! -d "/var/log/fullstack" ]; then
		mkdir "/var/log/fullstack"
	fi
    touch "/var/log/fullstack/install.log"

    # Permissions
    chown -R fullstack:fullstack "/opt/Full-Stack-Minecraft"
    chmod -R 755 "/opt/Full-Stack-Minecraft"
    chown -R fullstack:fullstack "/var/log/fullstack/update.log"
    chmod -R 755 "/var/log/fullstack/update.log"

    # Create cron job for automatic updates
    CRONTAB=/var/spool/cron/crontabs/fullstack
    if [[ -f "${CRONTAB}" ]]; then
        rm "${CRONTAB}"
    fi
    touch "${CRONTAB}"
    echo "5 * * * * bash /opt/Full-Stack-Minecraft/install.sh" | tee -a "${CRONTAB}"
    chmod 600 "${CRONTAB}"
    chown fullstack:fullstack "${CRONTAB}"

    exit
else
    if [ $USER == "fullstack" ]; then
        # Account check
        if [ ! -d "/opt/Full-Stack-Minecraft" ]; then
            echo "Please run this script as root or using sudo for the initial install"
            exit
        fi

        # Check for repository updates
        cd "/opt/Full-Stack-Minecraft"
        git fetch
        UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
        [[ $UPDATES =~ '([1-9]+|[1-9][0-9]+)' ]]
        if [ $UPDATES == $BASH_REMACH[1] ]; then
            # If updates exist, pull them
            echo "$(date +"%F %T"): ${UPDATES} found, updating..." | tee -a "/var/log/fullstack/update.log"
    		git pull
        else
            # No updates were found
            echo "$(date +"%F %T"): ${UPDATES} found." | tee -a "/var/log/fullstack/update.log"
        fi

        exit
    fi
fi

echo " "
echo "=== Full-Stack Minecraft V1 ==="
echo " "
echo "Please run this script as root for the initial install or to repair an existing install, or as user fullstack to check for updates."
echo " "
