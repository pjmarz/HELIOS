#!/bin/bash

# https://github.com/ThePornDatabase/ThePornDB.bundle
# https://github.com/PAhelper/PhoenixAdult.bundle
# https://github.com/Darklyter/StashPlexAgent.bundle

# TPDb API Key: Y0kXbIBEcZ36ukpCNWPrHecdZAtRePnGmFv6oB0u13fd0218

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Log file path
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/agent-bundle-update.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Define the Docker Compose project directory
DOCKER_COMPOSE_DIR="/home/peter/Documents/dev/HELIOS/Media Management Center"

# Log function to log messages with timestamps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Log the start of the script
log "Starting new script run"

# Stop Plex and PlexAutoLanguages Docker containers before updating
log "Stopping Plex and PlexAutoLanguages Docker containers..."
(cd "$DOCKER_COMPOSE_DIR" && docker compose stop plex plexautolanguages)

# Temporary directory for cloning
TEMP_DIR="/home/peter/transfer"

# Plex plugins directory
PLEX_PLUGINS_DIR="/home/peter/config/plexdb/Library/Application Support/Plex Media Server/Plug-ins"

# Repositories URLs and directory names
declare -A REPOS=(
    ["ThePornDB.bundle"]="https://github.com/ThePornDatabase/ThePornDB.bundle.git"
    ["PhoenixAdult.bundle"]="https://github.com/PAhelper/PhoenixAdult.bundle.git"
    ["StashPlexAgent.bundle"]="https://github.com/Darklyter/StashPlexAgent.bundle.git"
)

# Define the bundle names for ThePornDB
BUNDLES=("ThePornDBMovies.bundle" "ThePornDBScenes.bundle" "ThePornDBTrailer.bundle" "ThePornDBJAV.bundle")

(
# Function to clone or update a repository
update_repo() {
    local repo_dir="$1"
    local repo_url="$2"
    if [ -d "$TEMP_DIR/$repo_dir" ]; then
        log "Updating $repo_dir..."
        cd "$TEMP_DIR/$repo_dir" || exit
        git pull
    else
        log "Cloning $repo_dir..."
        mkdir -p "$TEMP_DIR"
        cd "$TEMP_DIR" || exit
        git clone "$repo_url"
    fi
}

# Update all repositories
for repo_dir in "${!REPOS[@]}"; do
    update_repo "$repo_dir" "${REPOS[$repo_dir]}"
done

# Move ThePornDB specified bundles to the Plex plugins directory, overwriting existing ones
for BUNDLE in "${BUNDLES[@]}"; do
    if [ -d "$TEMP_DIR/ThePornDB.bundle/$BUNDLE" ]; then
        log "Moving $BUNDLE to Plex plugins directory..."
        rm -rf "$PLEX_PLUGINS_DIR/$BUNDLE"
        mv "$TEMP_DIR/ThePornDB.bundle/$BUNDLE" "$PLEX_PLUGINS_DIR"
    else
        log "Warning: $BUNDLE not found in ThePornDB.bundle repository."
    fi
done

# Move PhoenixAdult.bundle and StashPlexAgent.bundle in their entirety
for repo_dir in "PhoenixAdult.bundle" "StashPlexAgent.bundle"; do
    if [ -d "$TEMP_DIR/$repo_dir" ]; then
        log "Moving $repo_dir to Plex plugins directory..."
        rm -rf "$PLEX_PLUGINS_DIR/$repo_dir"
        mv "$TEMP_DIR/$repo_dir" "$PLEX_PLUGINS_DIR"
    else
        log "Warning: $repo_dir not found in the cloned repository."
    fi
done

log "Update process completed."

# Delete the cloned Git repositories at the end
log "Removing cloned repositories..."
rm -rf "$TEMP_DIR"/*
log "Cloned repositories removed."
) | tee -a "$LOG_FILE"

# Restart Plex and PlexAutoLanguages Docker containers
log "Restarting Plex and PlexAutoLanguages Docker containers..."
(cd "$DOCKER_COMPOSE_DIR" && docker compose restart plex plexautolanguages)
log "Plex and PlexAutoLanguages have been restarted."