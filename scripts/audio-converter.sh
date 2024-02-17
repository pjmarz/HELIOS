#!/bin/bash
# This script sets the language metadata for all audio tracks to English
# for specified video file types within the root directory and its subdirectories.
# It skips files that already have English audio language.

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

# Function to set metadata
set_metadata() {
    local file="$1"
    local extension="$2"
    
    # Check if the language is already set to English using ffprobe
    echo "Checking language for $file"
    local lang=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 "$file")
    if [[ "$lang" == "eng" ]]; then
        echo "Skipping $file: language already set to English."
        return
    fi

    echo "Setting language to English for $file"
    local tmpfile="$(mktemp --suffix=".$extension")"

    # The ffmpeg command includes the '-y' flag to automatically overwrite the temporary file if it exists
    ffmpeg -hide_banner -loglevel error -y -i "$file" -metadata:s:a:0 language=eng -codec copy "$tmpfile" && mv -f "$tmpfile" "$file"
    
    echo "Language set to English for $file"
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

# Check if TOTAL is greater than 0 to avoid division by zero error
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

echo "Processing complete."
