#!/bin/bash
# This script sets the language metadata for audio tracks to English
# for specified video file types within the root directory and its subdirectories,
# but only if the current language is set to 'unknown'.
# It also logs any files that trigger a specific FFmpeg warning or error message.

echo "Starting script..."

# Root directory containing the media files
ROOT_DIRECTORY="/mnt/LOAS/xxx"

echo "Root directory set to $ROOT_DIRECTORY"

# Array of video file extensions to process
declare -a FILE_EXTENSIONS=("webm" "mkv" "flv" "vob" "ogv" "ogg" "rrc" "gifv"
                            "mng" "mov" "avi" "qt" "wmv" "yuv" "rm" "asf" "amv"
                            "mp4" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv"
                            "m4v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v"
                            "f4p" "f4a" "f4b" "mod")

# Log file for files that trigger the specific FFmpeg warning or error
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/audio-converter-errors.log"
: > "$LOG_FILE" # Empty the log file at the start of the script

# Function to set metadata
set_metadata() {
    local file="$1"
    local extension="$2"
    
    # Check the current language metadata using ffprobe
    echo "Checking language for $file"
    local lang=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 "$file")
    
    # If the language is 'unknown' or not set, then set it to English
    if [ -z "$lang" ] || [ "$lang" == "und" ]; then
        echo "Setting language to English for $file"
        local tmpfile="$(mktemp --suffix=".$extension")"
        local ffmpeg_output
        ffmpeg_output=$(ffmpeg -hide_banner -loglevel error -y -i "$file" -metadata:s:a:0 language=eng -codec copy "$tmpfile" 2>&1)
        local ffmpeg_exit_code=$?
        if mv -f "$tmpfile" "$file"; then
            echo "Language set to English for $file"
        else
            echo "Failed to set language for $file"
        fi
        if [[ "$ffmpeg_output" == *"Application provided duration"* ]]; then
            echo "$file" >> "$LOG_FILE"
        fi
    else
        echo "Skipping $file: language is already set to $lang."
    fi
}

# Count total number of files to process
echo "Counting total number of files to process..."
TOTAL=0
for extension in "${FILE_EXTENSIONS[@]}"; do
    count=$(find "$ROOT_DIRECTORY" -type f -name "*.$extension" 2>/dev/null | wc -l)
    echo "Found $count files with .$extension extension."
    TOTAL=$((TOTAL + count))
done

echo "Total number of files to process: $TOTAL"

# Exit if no files are found
if [ "$TOTAL" -le 0 ]; then
    echo "No files found to process. Please check your directory path and file extensions."
    exit 1
fi

# Export the function so it can be used by find -exec
export -f set_metadata

# Loop over each file type and apply the metadata changes
for extension in "${FILE_EXTENSIONS[@]}"; do
    echo "Processing .$extension files..."
    find "$ROOT_DIRECTORY" -type f -name "*.$extension" -exec bash -c 'set_metadata "$0" "$1"' {} "$extension" \;
done

# Display the log of files that triggered the specific FFmpeg warning or error
if [ -s "$LOG_FILE" ]; then
    echo "The following files triggered an FFmpeg warning or error:"
    cat "$LOG_FILE"
else
    echo "No files triggered the specific FFmpeg warning or error."
fi

echo "Processing complete."
