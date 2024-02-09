#!/bin/bash

# Define the base directory for completed downloads
BASE_DIR="/mnt/CHARON/sabnzbd/downloads/completed"

# Define the intermediate directory
INTERMEDIATE_DIR="/mnt/CHARON/sabnzbd/downloads/intermediate"

# Define the log directory
LOG_DIR="/home/peter/Documents/dev/HELIOS/script_logs"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Define log file name with date and time
LOG_FILE="${LOG_DIR}/clean-sabnzbd.log"

# Function to log to both terminal and file
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Delete all contents of the intermediate directory
log "Deleting all contents of $INTERMEDIATE_DIR"
rm -rf "${INTERMEDIATE_DIR:?}"/* | tee -a "$LOG_FILE"

# List of folders to clear within the completed directory
FOLDERS=("default" "movies" "tv" "xxx")

# Loop through each folder in the completed directory and delete its contents
for folder in "${FOLDERS[@]}"
do
    log "Deleting contents of $BASE_DIR/$folder"
    rm -rf "${BASE_DIR:?}/${folder:?}"/* | tee -a "$LOG_FILE"
done

log "All specified folders, including the intermediate directory, have been cleared."

# Notify end of script and log file location
echo "Script completed. Log file is located at $LOG_FILE"
