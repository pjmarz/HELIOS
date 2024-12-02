#!/bin/bash

# Define the Plex Docker container name directly
CONTAINER_NAME="plex"

# Define the logfile and Plex server details
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"

# Source the PLEX_TOKEN from environment
source /home/peter/Documents/dev/HELIOS/env.sh

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Starting Plex library update..."

# Define library sections with IDs and names
declare -A LIBRARY_SECTIONS
LIBRARY_SECTIONS=(
    [1]="TV Shows"
    [2]="Movies"
    [3]="Books"
)

# Function to update a single library section
update_library_section() {
    local section_id=$1
    local section_name=$2
    local response

    # Refresh library to scan new items
    log "Starting Plex library scan for section ${section_name} (ID: ${section_id})..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh" -H "X-Plex-Token: ${PLEX_TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error scanning library section ${section_name} (ID: ${section_id}): $response"
        return 1
    fi

    log "Waiting for library scan to complete for section ${section_name} (ID: ${section_id})..."
    sleep 60  # Wait for the library scan to complete

    # Refresh metadata for the library section
    log "Starting Plex metadata refresh for section ${section_name} (ID: ${section_id})..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1" -H "X-Plex-Token: ${PLEX_TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error refreshing metadata for section ${section_name} (ID: ${section_id}): $response"
        return 1
    fi

    log "Waiting for metadata refresh to complete for section ${section_name} (ID: ${section_id})..."
    sleep 3600  # Wait for the metadata refresh to complete

    # Analyze media in the library section
    log "Starting Plex media analysis for section ${section_name} (ID: ${section_id})..."
    response=$(curl -k -s -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${PLEX_TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error analyzing media for section ${section_name} (ID: ${section_id}): $response"
        return 1
    fi

    log "Waiting for media analysis to complete for section ${section_name} (ID: ${section_id})..."
    sleep 3600  # Wait for the media analysis to complete

    log "Library section ${section_name} (ID: ${section_id}) updated successfully."
}

# Iterate over each library section and update
for section_id in "${!LIBRARY_SECTIONS[@]}"; do
    update_library_section "$section_id" "${LIBRARY_SECTIONS[$section_id]}" || log "Update failed for section: ${LIBRARY_SECTIONS[$section_id]} (ID: $section_id)"
done

log "Plex library update tasks for all sections completed! Log file is located at $LOG_FILE"
