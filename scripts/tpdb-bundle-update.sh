#!/bin/bash

# https://github.com/ThePornDatabase/ThePornDB.bundle

# Log file path
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/tpdb-bundle-update.log"

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

# Repository URL
REPO_URL="https://github.com/ThePornDatabase/ThePornDB.bundle.git"

# Repository directory name after cloning
REPO_DIR="ThePornDB.bundle"

# Define the bundle names
BUNDLES=("ThePornDBMovies.bundle" "ThePornDBScenes.bundle" "ThePornDBTrailer.bundle" "ThePornDBJAV.bundle")

(
# Clone or update ThePornDB.bundle
if [ -d "$TEMP_DIR/$REPO_DIR" ]; then
  log "Updating ThePornDB.bundle..."
  cd "$TEMP_DIR/$REPO_DIR" || exit
  git pull
else
  log "Cloning ThePornDB.bundle..."
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR" || exit
  git clone "$REPO_URL"
fi

# Move the specified bundles to the Plex plugins directory, overwriting existing ones
for BUNDLE in "${BUNDLES[@]}"; do
  if [ -d "$TEMP_DIR/$REPO_DIR/$BUNDLE" ]; then
    log "Moving $BUNDLE to Plex plugins directory..."
    # Remove the existing bundle directory if it exists
    rm -rf "$PLEX_PLUGINS_DIR/$BUNDLE"
    # Move the new version of the bundle
    mv "$TEMP_DIR/$REPO_DIR/$BUNDLE" "$PLEX_PLUGINS_DIR"
  else
    log "Warning: $BUNDLE not found in the cloned repository."
  fi
done

log "Update process completed."

# Delete the cloned Git repository at the end
log "Removing cloned repository..."
rm -rf "$TEMP_DIR/$REPO_DIR"
log "Cloned repository removed."
) | tee -a "$LOG_FILE"

# Restart Plex and PlexAutoLanguages Docker containers
log "Restarting Plex and PlexAutoLanguages Docker containers..."
(cd "$DOCKER_COMPOSE_DIR" && docker compose restart plex plexautolanguages)
log "Plex and PlexAutoLanguages have been restarted."
