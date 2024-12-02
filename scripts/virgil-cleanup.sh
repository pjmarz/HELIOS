#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the log file
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/virgil-cleanup.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to log a message with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check the status of the last command and display an error if necessary
check_status() {
    local command="$1"
    local msg="$2"
    local status=$3

    if [ $status -ne 0 ]; then
        log_message "Error with command: $command - $msg"
        exit 1
    fi
}

# Request sudo privileges at the start
sudo -v
while true; do sudo -v; sleep 60; done & SESSION_PID=$!

# Start a new log session with a timestamp
log_message "Starting virgil cleanup process..."

# Update Ubuntu Pro services
log_message "Refreshing Ubuntu Pro services..."
sudo ua refresh | tee -a "$LOG_FILE"
check_status "sudo ua refresh" "Failed to refresh Ubuntu Pro services." $?

# Update package lists
log_message "Updating package lists..."
sudo apt-get update | tee -a "$LOG_FILE"
check_status "sudo apt-get update" "Failed to update package lists." $?

# Upgrade installed packages
log_message "Upgrading installed packages..."
sudo apt-get full-upgrade -y | tee -a "$LOG_FILE"
check_status "sudo apt-get full-upgrade" "Failed to upgrade installed packages." $?

# Remove unused packages and dependencies with purge
log_message "Removing unused packages and dependencies..."
sudo apt-get autoremove --purge -y | tee -a "$LOG_FILE"
check_status "sudo apt-get autoremove --purge" "Failed to remove unused packages and dependencies." $?

# Clean the package cache
log_message "Cleaning package cache..."
sudo apt-get clean | tee -a "$LOG_FILE"
check_status "sudo apt-get clean" "Failed to clean the package cache." $?

# Remove orphaned packages
log_message "Removing orphaned packages..."
OLD_CONFIGS=$(sudo dpkg --list | grep '^rc' | awk '{print $2}')
if [ -n "$OLD_CONFIGS" ]; then
    echo "$OLD_CONFIGS" | xargs sudo dpkg --purge | tee -a "$LOG_FILE"
    check_status "sudo dpkg --purge old configs" "Failed to remove orphaned packages." $?
fi

# Clear systemd journal logs
log_message "Clearing systemd journal logs..."
sudo journalctl --vacuum-time=7d | tee -a "$LOG_FILE"
check_status "sudo journalctl --vacuum-time=7d" "Failed to clear systemd journal logs." $?

# Clear the thumbnail cache for the current user if it exists
if [ -d ~/.cache/thumbnails ]; then
    log_message "Clearing thumbnail cache..."
    rm -rf ~/.cache/thumbnails/* | tee -a "$LOG_FILE"
    check_status "rm -rf ~/.cache/thumbnails/*" "Failed to clear thumbnail cache." $?
else
    log_message "Thumbnail cache not found. Skipping."
fi

# Clear the trash if it exists
if [ -d ~/.local/share/Trash ]; then
    log_message "Clearing trash..."
    rm -rf ~/.local/share/Trash/* | tee -a "$LOG_FILE"
    check_status "rm -rf ~/.local/share/Trash/*" "Failed to clear trash." $?
else
    log_message "Trash directory not found. Skipping."
fi

# End sudo session
kill $SESSION_PID

log_message "System cleanup complete! Log file is located at $LOG_FILE"
