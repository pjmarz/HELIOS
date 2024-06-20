#!/bin/bash

# Define the Plex Docker container name directly
CONTAINER_NAME="plex"

# Define the logfile and Plex server details
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"
TOKEN="9_nBV2e7ArYx8JPEhasy"
LIBRARY_SECTION_IDS=("1" "2" "3")  # Array of library IDs

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Starting Plex library update..."

# Function to update a single library section
update_library_section() {
    local section_id=$1
    local response

    log "Starting Plex library scan for section ${section_id}..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh" -H "X-Plex-Token: ${TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error updating library section ${section_id}: $response"
        return 1
    fi

    sleep 10

    log "Starting Plex metadata refresh for section ${section_id}..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1&X-Plex-Token=${TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error refreshing metadata for section ${section_id}: $response"
        return 1
    fi

    sleep 1800

    log "Starting Plex media analysis for section ${section_id}..."
    response=$(curl -k -s -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error analyzing media for section ${section_id}: $response"
        return 1
    fi
    
    sleep 1800
}

# Iterate over each library section and update
for section_id in "${LIBRARY_SECTION_IDS[@]}"; do
    update_library_section "$section_id" || log "Update failed for section: $section_id"
done

log "Plex library update tasks for all sections completed! Log file is located at $LOG_FILE"
