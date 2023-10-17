#!/bin/bash

LOGFILE="/home/peter/Documents/dev/HELIOS/script logs/plex_auto_update.log"
PLEX_URL="http://192.168.1.45:32400"
TOKEN="reKFC-C828Gqv6aJ2ehG"

# Redirect all output (stdout and stderr) to the LOGFILE
exec > "$LOGFILE" 2>&1

# Function to display a countdown timer
countdown() {
    local duration=$1
    while [ $duration -gt 0 ]; do
        printf "\rWaiting for %02d seconds before the next task..." $duration
        sleep 1
        ((duration--))
    done
    echo "" # Move to a new line after countdown completes
}

# Start Plex library scan
echo "Starting Plex library scan..."
curl -X PUT "${PLEX_URL}/library/sections/7/refresh?X-Plex-Token=${TOKEN}"
countdown 30

# Start Plex media analysis
echo "Starting Plex media analysis..."
curl -X PUT "${PLEX_URL}/library/sections/7/analyze?X-Plex-Token=${TOKEN}"
countdown 600

# Start Plex metadata refresh
echo "Starting Plex metadata refresh..."
curl -X PUT "${PLEX_URL}/library/sections/7/refresh?force=1&X-Plex-Token=${TOKEN}"

echo "All tasks completed!"
