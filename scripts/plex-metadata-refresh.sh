#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-metadata-refresh.log"
PLEX_CONFIG_DIR="${ROOT}/config/plexdb/Library/Application Support/Plex Media Server"
CONTAINER_NAME="plex"

# Define the Plex server details
PLEX_URL="https://192.168.1.45:32400"
TOKEN="reKFC-C828Gqv6aJ2ehG"
LIBRARY_SECTION_IDS=("1" "2" "3")  # Array of library IDs

# Function to log to file and console
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

# Stop Plex Docker container
log "Stopping Plex Docker container..."
docker stop "$CONTAINER_NAME"
log "Plex Docker container stopped."

# Remove specific directories except for 'Playlists'
PLEX_METADATA_DIR="$PLEX_CONFIG_DIR/Metadata"
log "Removing metadata except for 'Playlists'..."
find "$PLEX_METADATA_DIR" -mindepth 1 -maxdepth 1 ! -name 'Playlists' -exec rm -rf {} \; 2>/dev/null
log "Metadata removal complete."

# Remove subdirectories of 'localhost' under 'Media'
PLEX_LOCALHOST_DIR="$PLEX_CONFIG_DIR/Media/localhost"
log "Removing subdirectories of 'localhost' under 'Media'..."
if [ -d "$PLEX_LOCALHOST_DIR" ]; then
    find "$PLEX_LOCALHOST_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \; 2>/dev/null
    log "Subdirectories removal complete."
else
    log "The 'localhost' directory does not exist or has already been removed."
fi

# Remove Plug-in Support Caches
PLEX_PLUGIN_SUPPORT_CACHES_DIR="$PLEX_CONFIG_DIR/Plug-in Support/Caches"
log "Removing Plug-in Support Caches..."
find "$PLEX_PLUGIN_SUPPORT_CACHES_DIR" -mindepth 1 -type d -exec rm -rf {} \; 2>/dev/null
log "Plug-in Support Caches removal complete."

# Restart Plex Docker container
log "Restarting Plex Docker container..."
docker restart "$CONTAINER_NAME"
log "Plex Docker container restarted. Waiting for Plex to be fully operational..."

# Wait a bit to ensure Plex is fully up
sleep 60

log "Initiating refresh of all metadata for specified library sections..."

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

# End of script
log "Plex metadata refresh complete."
