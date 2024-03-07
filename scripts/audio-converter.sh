#!/bin/bash

# This script sets the language metadata for audio tracks to English
# for specified video file types within the root directory and its subdirectories,
# but only if the current language is set to 'unknown'.

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

# Function to set metadata
set_metadata() {
    local file="$1"
    local extension="$2"
    local ffmpeg_log="/tmp/ffmpeg_$$.log" # Temporary file for FFmpeg logs

    # Check the current language metadata using ffprobe
    local lang=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 "$file")
    
    # If the language is 'unknown' or not set, then set it to English
    if [ -z "$lang" ] || [ "$lang" == "und" ]; then
        echo "Setting language to English for $file"
        ffmpeg -hide_banner -y -i "$file" -metadata:s:a:0 language=eng -codec copy "$file".tmp > "$ffmpeg_log" 2>&1

        # Check if FFmpeg log contains any messages
        if [ -s "$ffmpeg_log" ]; then
            # Log the FFmpeg output
            echo "FFmpeg output for $file:" >> "$LOG_FILE"
            cat "$ffmpeg_log" >> "$LOG_FILE"
        else
            mv "$file".tmp "$file"
            echo "Language set to English for $file"
        fi
    else
        echo "Skipping $file: language is already set to $lang."
    fi

    rm -f "$ffmpeg_log" # Clean up the temporary FFmpeg log file
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

log "Audio metadata conversion complete."
