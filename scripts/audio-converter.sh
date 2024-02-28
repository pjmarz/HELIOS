#!/bin/bash
# This script sets the language metadata for audio tracks to English
# for specified video file types within the root directory and its subdirectories,
# but only if the current language is set to 'unknown'.
# It also logs any files that trigger a specific FFmpeg warning or error message.

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/audio-converter.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Starting script..."

# Root directory containing the media files
ROOT_DIRECTORY="/mnt/LOAS/xxx"
log "Root directory set to $ROOT_DIRECTORY"

# Array of video file extensions to process
declare -a FILE_EXTENSIONS=("webm" "mkv" "flv" "vob" "ogv" "ogg" "rrc" "gifv"
                            "mng" "mov" "avi" "qt" "wmv" "yuv" "rm" "asf" "amv"
                            "mp4" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv"
                            "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v"
                            "f4p" "f4a" "f4b" "mod")

# Function to set metadata, note: 'echo' commands inside this function will not have timestamps
# Consider logging these internally or ensure this detail is acceptable for your logging requirements
set_metadata() {
    local file="$1"
    local extension="$2"
    ...
}

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
export -f set_metadata

# Loop over each file type and apply the metadata changes
for extension in "${FILE_EXTENSIONS[@]}"; do
    log "Processing .$extension files..."
    find "$ROOT_DIRECTORY" -type f -name "*.$extension" -exec bash -c 'set_metadata "$0" "$1"' {} "$extension" \;
done

# Display the log of files that triggered the specific FFmpeg warning or error
if [ -s "$LOG_FILE" ]; then
    log "The following files triggered an FFmpeg warning or error:"
    cat "$LOG_FILE" # This cat command won't have timestamps per line, consider if this meets your needs
else
    log "No files triggered the specific FFmpeg warning or error."
fi

log "Processing complete."
