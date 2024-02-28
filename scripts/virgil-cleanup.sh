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
    if [ $? -ne 0 ]; then
        log_message "Error with command: $1"
        exit 1
    fi
}

# Start a new log session with a timestamp
log_message "Starting virgil_cleanup process..."

# Update Ubuntu Pro services
sudo ua refresh | tee -a "$LOG_FILE"
check_status "sudo ua refresh"

# Update package lists
sudo apt-get update | tee -a "$LOG_FILE"
check_status "sudo apt-get update"

# Upgrade installed packages more aggressively
sudo apt-get full-upgrade -y | tee -a "$LOG_FILE"
check_status "sudo apt-get full-upgrade"

# Remove unused packages and dependencies
sudo apt-get autoremove -y | tee -a "$LOG_FILE"
check_status "sudo apt-get autoremove"

# Clean the package cache
sudo apt-get clean | tee -a "$LOG_FILE"
check_status "sudo apt-get clean"

# Remove old kernels (if any)
sudo apt-get --purge autoremove -y | tee -a "$LOG_FILE"
check_status "sudo apt-get --purge autoremove"

# Remove orphaned packages
sudo deborphan | xargs sudo apt-get -y remove --purge | tee -a "$LOG_FILE"
check_status "sudo deborphan | xargs sudo apt-get remove"

# Remove old configuration files
OLD_CONFIGS=$(sudo dpkg --list | grep '^rc' | awk '{print $2}')
if [ -n "$OLD_CONFIGS" ]; then
    echo "$OLD_CONFIGS" | xargs sudo dpkg --purge | tee -a "$LOG_FILE"
    check_status "sudo dpkg --purge old configs"
fi

# Clear systemd journal logs
sudo journalctl --vacuum-time=3d | tee -a "$LOG_FILE"
check_status "sudo journalctl --vacuum-time=3d"

# Clear the thumbnail cache for the current user
rm -rf ~/.cache/thumbnails/* | tee -a "$LOG_FILE"
check_status "rm -rf ~/.cache/thumbnails/*"

# Clear the trash
rm -rf ~/.local/share/Trash/* | tee -a "$LOG_FILE"
check_status "rm -rf ~/.local/share/Trash/*"

log_message "System cleanup complete!"
