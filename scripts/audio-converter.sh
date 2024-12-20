#!/bin/bash
# This script sets the language metadata for audio tracks to English
# for specified video file types within the root directory and its subdirectories,
# but only if the current language is set to 'unknown', and updates Plex metadata.

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/audio-converter.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to log with timestamp
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1"
}

log "Starting script..."

# Root directory containing the media files
ROOT_DIRECTORY="${LOAS}/xxx"

log "Root directory set to $ROOT_DIRECTORY"

# Array of video file extensions to process
declare -a FILE_EXTENSIONS=("webm" "mkv" "flv" "vob" "ogv" "ogg" "rrc" "gifv"
                            "mng" "mov" "avi" "qt" "wmv" "yuv" "rm" "asf" "amv"
                            "mp4" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv"
                            "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v"
                            "f4p" "f4a" "f4b" "mod")

# Plex server details
PLEX_SERVER="https://192.168.1.45:32400"

# Function to set metadata
set_metadata() {
    local file="$1"
    local extension="$2"
    
    # Check the current language metadata using ffprobe
    log "Checking language for $file"
    local lang=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 "$file")
    
    # If the language is 'unknown' or not set, then set it to English
    if [ -z "$lang" ] || [ "$lang" == "und" ]; then
        log "Setting language to English for $file"
        local tmpfile="$(mktemp --suffix=".$extension")"
        ffmpeg -hide_banner -loglevel error -y -i "$file" -metadata:s:a:0 language=eng -codec copy "$tmpfile" && mv -f "$tmpfile" "$file"
        log "Language set to English for $file"
        
        # Update Plex metadata
        update_plex_metadata "$file"
    else
        log "Skipping $file: language is already set to $lang."
    fi
}

# Function to update Plex metadata
update_plex_metadata() {
    local file="$1"
    log "Updating Plex metadata for $file"
    local filepath=$(echo "$file" | sed 's/ /%20/g')
    curl -X PUT "${PLEX_SERVER}/library/sections/all/refresh?path=${filepath}&X-Plex-Token=${PLEX_TOKEN}"
    log "Plex metadata updated for $file"
}

# Count total number of files to process
log "Counting total number of files to process..."
TOTAL=0
for extension in "${FILE_EXTENSIONS[@]}"; do
    count=$(find "$ROOT_DIRECTORY" -type f -name "*.$extension" 2>/dev/null | wc -l)
    log "Found $count files with .$extension extension."
    TOTAL=$((TOTAL + count))
done

log "Total number of files to process: $TOTAL"

# Exit if no files are found
if [ "$TOTAL" -le 0 ]; then
    log "No files found to process. Please check your directory path and file extensions."
    exit 1
fi

# Export the function so it can be used by find -exec
export -f log
export -f set_metadata
export -f update_plex_metadata

# Export Plex token to be used in the script
export PLEX_TOKEN

# Loop over each file type and apply the metadata changes
for extension in "${FILE_EXTENSIONS[@]}"; do
    log "Processing .$extension files..."
    find "$ROOT_DIRECTORY" -type f -name "*.$extension" -exec bash -c 'set_metadata "$0" "$1"' {} "$extension" \;
done

log "Audio conversion complete. Log file is located at $LOG_FILE"
