#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/restart_docker.log"

# Redirect all output (stdout and stderr) to the LOGFILE
exec > "$LOGFILE" 2>&1

echo "$(date) - Starting the Docker restart process..." | tee -a "$LOGFILE"

# Check Docker service status
echo "Checking Docker service status..." | tee -a "$LOGFILE"
if systemctl is-active --quiet docker; then
    echo "Docker is active." | tee -a "$LOGFILE"
else
    echo "Docker is not active. Attempting to start..." | tee -a "$LOGFILE"
fi

# Restart Docker service
echo "Restarting Docker service..." | tee -a "$LOGFILE"
sudo service docker restart
if [ $? -ne 0 ]; then
    echo "Error restarting Docker service. Exiting." | tee -a "$LOGFILE"
    exit 1
fi

# Navigate to your docker compose directory
echo "Navigating to docker compose directory..." | tee -a "$LOGFILE"
cd /home/peter/Documents/dev/HELIOS
if [ $? -ne 0 ]; then
    echo "Error navigating to docker compose directory. Exiting." | tee -a "$LOGFILE"
    exit 1
fi

# Run docker compose up in detached mode
echo "Running docker compose up in detached mode..." | tee -a "$LOGFILE"
docker compose up -d
if [ $? -ne 0 ]; then
    echo "Error running docker compose up. Exiting." | tee -a "$LOGFILE"
    exit 1
fi

# Check Docker Compose services status
echo "Checking Docker Compose services status..." | tee -a "$LOGFILE"
docker compose ps | tee -a "$LOGFILE"

echo "Process completed!" | tee -a "$LOGFILE"
