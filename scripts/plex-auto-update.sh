#!/bin/bash

# Define the logfile and Plex server details
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"
TOKEN="reKFC-C828Gqv6aJ2ehG"
LIBRARY_SECTION_IDS=("1" "2" "3")  # Array of library IDs

# Redirect all output to the logfile
exec > "$LOGFILE" 2>&1

echo "$(date) - Starting Plex library update..."

# Function to update a single library section
update_library_section() {
    local section_id=$1
    echo "Starting Plex library scan for section ${section_id}..."
    curl -k -L -X GET "${PLEX_URL}/library/sections/${section_id}/refresh" -H "X-Plex-Token: ${TOKEN}"

    sleep 60

    echo "Starting Plex media analysis for section ${section_id}..."
    curl -k -L -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${TOKEN}"

    sleep 3600

    echo "Starting Plex metadata refresh for section ${section_id}..."
    curl -k -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1&X-Plex-Token=${TOKEN}"
}

# Iterate over each library section and update
for section_id in "${LIBRARY_SECTION_IDS[@]}"; do
    update_library_section "$section_id"
done

echo "Plex library update tasks for all sections completed!"
