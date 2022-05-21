if [ `whoami` == "root" ]; then
    # Create log directory and associated logs
    if [ ! -d "/var/log/fullstack" ]; then
        mkdir "/var/log/fullstack"
        touch "/var/log/fullstack/update.log"
        echo "$(date +"%F %T"): Installing Full-Stack-Minecraft..." | tee -a "/var/log/fullstack/update.log"
    else
        echo "$(date +"%F %T"): Repairing Full-Stack-Minecraft install..." | tee -a "/var/log/fullstack/update.log"
    fi

    # Create new user account fullstack
    if [ 0 == `getent passwd fullstack | wc -l` ]; then
        echo "$(date +"%F %T"): Creating new user account: fullstack" | tee -a "/var/log/fullstack/update.log"
        # Check if fullstack user password was provided
        if [ ! ${1} ]; then
            echo "Please provide a password for new user account: fullstack"
            echo "$(date +"%F %T"): No password provided for new user account exiting." | tee -a "/var/log/fullstack/update.log"
            exit
        else
            # Add fullstack user
            useradd -m -s /bin/bash fullstack

            # Set fullstack user password
            echo "fullstack:${1}" | chpasswd
        fi
    fi

    # Update user account fullstack password
    if [ ${1} ]; then
        echo "$(date +"%F %T"): Updating fullstack user account password." | tee -a "/var/log/fullstack/update.log"
        echo "fullstack:${1}" | chpasswd
    fi

    # Clone the repository
    if [ -d "/opt/Full-Stack-Minecraft" ]; then
        echo "$(date +"%F %T"): Removing existing local repository..." | tee -a "/var/log/fullstack/update.log"
        rm -rf "/opt/Full-Stack-Minecraft"
    fi
    echo "$(date +"%F %T"): Cloning repository..." | tee -a "/var/log/fullstack/update.log"
    git clone "https://github.com/supergnaw/Full-Stack-Minecraft.git" "/opt/Full-Stack-Minecraft"

    # Create cron job for automatic updates
    echo "$(date +"%F %T"): Creating automatic updates cron job..." | tee -a "/var/log/fullstack/update.log"
    CRONTAB=/var/spool/cron/crontabs/fullstack
    if [[ -f "${CRONTAB}" ]]; then
        rm "${CRONTAB}"
    fi
    touch "${CRONTAB}"
    echo "5 * * * * bash /opt/Full-Stack-Minecraft/install.sh" | tee -a "${CRONTAB}"

    # Permissions
    echo "$(date +"%F %T"): Updating permissions..." | tee -a "/var/log/fullstack/update.log"
    chown -R fullstack:fullstack "/opt/Full-Stack-Minecraft"
    chmod -R 755 "/opt/Full-Stack-Minecraft"
    chown -R fullstack:fullstack "/var/log/fullstack"
    chmod -R 755 "/var/log/fullstack"
    chmod 600 "${CRONTAB}"
    chown fullstack:fullstack "${CRONTAB}"

    # Complete!
    echo "$(date +"%F %T"): Complete!" | tee -a "/var/log/fullstack/update.log"
    exit
else
    if [ $USER == "fullstack" ]; then
        # Account check
        if [ ! -d "/opt/Full-Stack-Minecraft" ]; then
            echo "Please run this script as root or using sudo for the initial install"
            exit
        else
            echo "$(date +"%F %T"): Checking for updates..." | tee -a "/var/log/fullstack/update.log"
        fi

        # Check for repository updates
        cd "/opt/Full-Stack-Minecraft"
        git config core.fileMode false
        git fetch
        UPDATES=`git diff --shortstat origin/main | wc -l`
        if [[ 0 -eq ${UPDATES} ]]; then
            # No updates were found
            echo "$(date +"%F %T"): no changes found, no updates required." | tee -a "/var/log/fullstack/update.log"
        else
            # If updates exist, pull them
            UPDATES=`git diff --shortstat origin | cut -d " " -f 2`
            echo "$(date +"%F %T"): ${UPDATES} changes found, updating..." | tee -a "/var/log/fullstack/update.log"
    		git pull
        fi

        # Complete!
        echo "$(date +"%F %T"): Complete!" | tee -a "/var/log/fullstack/update.log"
        exit
    else
        if [ -f "/var/log/fullstack/update.log" ]; then
            echo "$(date +"%F %T"): script ran under user ${USER}" | tee -a "/var/log/fullstack/update.log"
        else
            echo " "
            echo "=== Full-Stack Minecraft V1 ==="
            echo " "
            echo "Please run this script as root for the initial install or to repair an existing install, or as user fullstack to check for updates."
            echo " "
        fi
    fi
fi
