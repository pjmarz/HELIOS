#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the logfile and Plex server details
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"
TOKEN="reKFC-C828Gqv6aJ2ehG"
LIBRARY_SECTION_IDS=("1" "2" "3")  # Array of library IDs

# Function to log a message
log_message() {
    echo "$(date) - $1" | tee -a "$LOGFILE"
}

echo "$(date) - Starting Plex library update..."

# Function to update a single library section
update_library_section() {
    local section_id=$1
    local response

    echo "Starting Plex library scan for section ${section_id}..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh" -H "X-Plex-Token: ${TOKEN}")
    if [[ $? -ne 0 ]]; then
        echo "Error updating library section ${section_id}: $response"
        return 1
    fi

    sleep 60

    echo "Starting Plex metadata refresh for section ${section_id}..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1&X-Plex-Token=${TOKEN}")
    if [[ $? -ne 0 ]]; then
        echo "Error refreshing metadata for section ${section_id}: $response"
        return 1
    fi

    sleep 3600

    echo "Starting Plex media analysis for section ${section_id}..."
    response=$(curl -k -s -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${TOKEN}")
    if [[ $? -ne 0 ]]; then
        echo "Error analyzing media for section ${section_id}: $response"
        return 1
    fi
    
}

# Iterate over each library section and update
for section_id in "${LIBRARY_SECTION_IDS[@]}"; do
    update_library_section "$section_id" || echo "Update failed for section: $section_id"
done

echo "Plex library update tasks for all sections completed!"
