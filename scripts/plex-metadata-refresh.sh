#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-metadata-refresh.log"
PLEX_CONFIG_DIR="${ROOT}/config/plexdb/Library/Application Support/Plex Media Server"
CONTAINER_NAME="plex"
PAL_CONTAINER_NAME="plexautolanguages"  # Added variable for plexautolanguages container

# Define the Plex server details
PLEX_URL="https://192.168.1.45:32400"
TOKEN="reKFC-C828Gqv6aJ2ehG"
LIBRARY_SECTION_IDS=("1" "2" "3")  # Array of library IDs

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Starting Plex and plexautolanguages update..."

# Stop plexautolanguages Docker container
log "Stopping plexautolanguages Docker container..."
docker stop "$PAL_CONTAINER_NAME"
log "plexautolanguages Docker container stopped."

# Stop Plex Docker container
log "Stopping Plex Docker container..."
docker stop "$CONTAINER_NAME"
log "Plex Docker container stopped."

# Restart Plex Docker container
log "Restarting Plex Docker container..."
docker restart "$CONTAINER_NAME"
log "Plex Docker container restarted. Waiting for Plex to be fully operational..."

# Wait a bit to ensure Plex is fully up
sleep 15

# Restart plexautolanguages Docker container
log "Restarting plexautolanguages Docker container..."
docker start "$PAL_CONTAINER_NAME"
log "plexautolanguages Docker container restarted."

# Wait a bit to ensure Plex is fully up
sleep 60

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

    sleep 60

    log "Starting Plex metadata refresh for section ${section_id}..."
    response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1&X-Plex-Token=${TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error refreshing metadata for section ${section_id}: $response"
        return 1
    fi

    sleep 3600

    log "Starting Plex media analysis for section ${section_id}..."
    response=$(curl -k -s -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${TOKEN}")
    if [[ $? -ne 0 ]]; then
        log "Error analyzing media for section ${section_id}: $response"
        return 1
    fi
    
    sleep 3600

}

# Iterate over each library section and update
for section_id in "${LIBRARY_SECTION_IDS[@]}"; do
    update_library_section "$section_id" || log "Update failed for section: $section_id"
done

log "Plex library update tasks for all sections completed!"

# Function to optimize Plex database
optimize_database() {
    log "Optimizing Plex database..."
    docker exec "$CONTAINER_NAME" /usr/lib/plexmediaserver/Plex\ Media\ Scanner --optimize --verbose --force
    log "Plex database optimization complete."
}

# Function to clean Plex bundles
clean_bundles() {
    log "Cleaning Plex bundles..."
    docker exec "$CONTAINER_NAME" /usr/lib/plexmediaserver/Plex\ Media\ Scanner --cleanup --verbose --force
    log "Plex bundles cleaned."
}

optimize_database
clean_bundles

log "Plex metadata refresh complete."
