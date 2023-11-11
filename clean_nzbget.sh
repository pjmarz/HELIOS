#!/bin/bash

# Define the base directory
BASE_DIR="/mnt/CHARON/nzbget/downloads"

# Define the directories to clear
DIRECTORIES=("completed" "intermediate" "nzb")

# Loop through each directory and clear its contents
for DIR in "${DIRECTORIES[@]}"; do
    echo "Clearing contents of $DIR"
    sudo rm -rf "${BASE_DIR}/${DIR}/"*
done

echo "Contents of specified directories cleared."