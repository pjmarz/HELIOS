#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

LOGFILE="/home/peter/Documents/dev/HELIOS/docker_restart.log"

echo "$(date) - Starting the Docker restart process..." | tee -a $LOGFILE

# Function to display a progress bar
progress_bar() {
    local duration=$1
    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

    for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
        already_done; remaining; percentage
        sleep 1
        clean_line
    done
    echo ""
}

# Check Docker service status
echo "Checking Docker service status..." | tee -a $LOGFILE
if systemctl is-active --quiet docker; then
    echo "Docker is active." | tee -a $LOGFILE
else
    echo "Docker is not active. Attempting to start..." | tee -a $LOGFILE
fi

# Restart Docker service
echo "Restarting Docker service..." | tee -a $LOGFILE
sudo service docker restart
if [ $? -ne 0 ]; then
    echo "Error restarting Docker service. Exiting." | tee -a $LOGFILE
    exit 1
fi
progress_bar 5

# Navigate to your docker compose directory
echo "Navigating to docker compose directory..." | tee -a $LOGFILE
cd /home/peter/Documents/dev/HELIOS
if [ $? -ne 0 ]; then
    echo "Error navigating to docker compose directory. Exiting." | tee -a $LOGFILE
    exit 1
fi
progress_bar 2

# Run docker compose up in detached mode
echo "Running docker compose up in detached mode..." | tee -a $LOGFILE
docker compose up -d
if [ $? -ne 0 ]; then
    echo "Error running docker compose up. Exiting." | tee -a $LOGFILE
    exit 1
fi
progress_bar 5

# Check Docker Compose services status
echo "Checking Docker Compose services status..." | tee -a $LOGFILE
docker compose ps | tee -a $LOGFILE

echo "Process completed!" | tee -a $LOGFILE
