#!/bin/bash

# Define the logfile and Plex server details
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/plex_auto_update.log"
PLEX_URL="http://192.168.1.45:32400"
TOKEN="kn5myHmFyQy2HgqzWZ4T"
LIBRARY_SECTION_ID="1" # Adjust the library section ID as needed

# Redirect all output to the logfile
exec > "$LOGFILE" 2>&1

echo "$(date) - Starting Plex library update..."

# Scan the library section for new content
echo "Starting Plex library scan..."
curl -X GET "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/scan?X-Plex-Token=${TOKEN}"

# Analyze media files in the library section to gather detailed information
echo "Starting Plex media analysis..."
curl -X PUT "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/analyze?X-Plex-Token=${TOKEN}"

# Refresh all metadata for the library section
echo "Starting Plex metadata refresh..."
curl -X PUT "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/refresh?force=1&X-Plex-Token=${TOKEN}"

echo "Plex library update tasks completed!"
