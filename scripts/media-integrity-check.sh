#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

echo "Starting integrity check..."

# Root directory containing the media files
ROOT_DIRECTORY="/mnt/LOAS"

echo "Root directory set to $ROOT_DIRECTORY"

# Array of video file extensions to process
declare -a FILE_EXTENSIONS=("webm" "mkv" "flv" "vob" "ogv" "ogg" "rrc" "gifv"
                            "mng" "mov" "avi" "qt" "wmv" "yuv" "rm" "asf" "amv"
                            "mp4" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv"
                            "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v"
                            "f4p" "f4a" "f4b" "mod")

# Log file for files that `ffmpeg` cannot process
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/media-integrity-check.log"

# Function to log to file and console
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

# Prepare the log file
: > "$LOG_FILE" # Empty the log file at the start of the script

# Function to check file integrity
check_integrity() {
    local file="$1"
    
    log "Checking integrity for $file"
    if ! ffmpeg -v error -i "$file" -f null - 2>&1 | tee -a "$LOG_FILE"; then
        log "Error found in $file, see $LOG_FILE for details."
    else
        log "$file: OK"
    fi
}

# Count total number of files to process and log the count
TOTAL=0
for extension in "${FILE_EXTENSIONS[@]}"; do
    count=$(find "$ROOT_DIRECTORY" -type f -name "*.$extension" 2>/dev/null | wc -l)
    log "Found $count files with .$extension extension."
    TOTAL=$((TOTAL + count))
done

log "Total number of files to process: $TOTAL"

# Exit if no files are found and log the status
if [ "$TOTAL" -le 0 ]; then
    log "No files found to process. Please check your directory path and file extensions."
    exit 1
fi

# Export the function so it can be used by find -exec
export -f check_integrity

# Loop over each file type and check the integrity
for extension in "${FILE_EXTENSIONS[@]}"; do
    echo "Checking integrity of .$extension files..."
    find "$ROOT_DIRECTORY" -type f -name "*.$extension" -exec bash -c 'file="$1"; echo "Checking integrity for $file"; if ! ffmpeg -v error -i "$file" -f null - 2>&1 | tee -a "/home/peter/Documents/dev/HELIOS/script_logs/media-integrity-check.log"; then echo "Error found in $file, see /home/peter/Documents/dev/HELIOS/script_logs/media-integrity-check.log for details."; else echo "$file: OK"; fi' bash {} \;
done

# Final log statements based on the process outcome
if [ -s "$LOG_FILE" ]; then
    log "The following files had issues during processing. See $LOG_FILE for details:"
    cat "$LOG_FILE"
else
    log "All files processed successfully. No issues found."
fi

log "Integrity check complete."
