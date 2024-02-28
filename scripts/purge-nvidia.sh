#!/bin/bash

# Script to uninstall all NVIDIA related components from Ubuntu 22.04

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/purge-nvidia.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to execute a command, log its action, and check for errors
execute_and_log() {
    local command="$@"
    log "Executing: $command"
    eval $command
    if [ $? -ne 0 ]; then
        log "Error executing: $command"
    fi
}

log "Starting NVIDIA components removal process."

execute_and_log sudo apt-get remove --purge '^nvidia-.*'
execute_and_log sudo apt-get remove --purge cuda-toolkit-12-3 libnvidia-encode-535
execute_and_log sudo systemctl stop nvidia-persistenced
execute_and_log sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia
execute_and_log sudo apt-get remove --purge nvidia-container-toolkit
execute_and_log sudo apt-get remove --purge cuda-keyring
execute_and_log sudo rm /etc/modprobe.d/blacklist-nouveau.conf
execute_and_log sudo update-initramfs -u
execute_and_log sudo apt-get autoremove -y
execute_and_log sudo apt-get autoclean

log "System needs to be rebooted. Please reboot the system manually."
