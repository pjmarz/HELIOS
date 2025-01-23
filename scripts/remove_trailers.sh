#!/bin/bash

# Paths to your media directories
MOVIES_PATH="/mnt/media/movies"
TV_PATH="/mnt/media/tv"

# Function to remove movie trailers
remove_movie_trailers() {
    echo "Scanning movie folders for trailers..."
    find "$MOVIES_PATH" -type f -iname "*trailer*" -exec rm -v {} \;
}

# Function to remove TV show Trailers folders
remove_tv_trailers() {
    echo "Scanning TV show folders for 'Trailers' directories..."
    find "$TV_PATH" -type d -iname "trailers" -exec rm -rv {} \;
}

# Execute the functions
remove_movie_trailers
remove_tv_trailers

echo "Trailer removal completed."
