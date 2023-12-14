#!/bin/bash

# Define the logfile and Plex server details
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"
TOKEN="kn5myHmFyQy2HgqzWZ4T"
LIBRARY_SECTION_ID="1"

# Redirect all output to the logfile
exec > "$LOGFILE" 2>&1

echo "$(date) - Starting Plex library update..."

# Scan the library section for new content
echo "Starting Plex library scan..."
curl -k -L -X GET "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/refresh" -H "X-Plex-Token: ${TOKEN}"

sleep 600

# Analyze media files in the library section
echo "Starting Plex media analysis..."
curl -k -L -X PUT "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/analyze" -H "X-Plex-Token: ${TOKEN}"

sleep 2700

# Refresh all metadata for the library section
echo "Starting Plex metadata refresh..."
curl -k -X GET "${PLEX_URL}/library/sections/${LIBRARY_SECTION_ID}/refresh?force=1&X-Plex-Token=${TOKEN}"

echo "Plex library update tasks completed!"
