#!/bin/bash

# Script to uninstall all NVIDIA related components from Ubuntu

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
        exit 1 # Exit script if an error occurs
    fi
}

log "Starting NVIDIA components removal process."

# Dynamically remove NVIDIA driver packages
execute_and_log sudo apt-get remove --purge '^nvidia-.*'

# Dynamically remove CUDA toolkit packages
cuda_packages=$(dpkg -l | grep -E 'cuda-|nvidia-cuda' | awk '{print $2}')
for package in $cuda_packages; do
    execute_and_log sudo apt-get remove --purge "$package"
done

# Dynamically remove any other NVIDIA related packages (libraries, encoders, etc.)
nvidia_related_packages=$(dpkg -l | grep -E 'libnvidia-|nvidia-' | awk '{print $2}')
for package in $nvidia_related_packages; do
    execute_and_log sudo apt-get remove --purge "$package"
done

# Stop NVIDIA persistence daemon
execute_and_log sudo systemctl stop nvidia-persistenced

# Remove NVIDIA kernel modules
execute_and_log sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia

# Remove NVIDIA container toolkit, if installed
execute_and_log sudo apt-get remove --purge '^nvidia-container.*'

# Remove any other residual configuration files
execute_and_log sudo apt-get autoremove -y
execute_and_log sudo apt-get autoclean

# Update initramfs
execute_and_log sudo update-initramfs -u

log "System needs to be rebooted. Please reboot the system manually."
