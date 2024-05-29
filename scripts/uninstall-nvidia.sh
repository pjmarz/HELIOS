#!/bin/bash

# Script to uninstall NVIDIA-related components from Ubuntu

# Define paths and log file
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/uninstall-nvidia.log"
LOG_DIR="$(dirname "$LOG_FILE")"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Clear the log file at the beginning of the script
: > "$LOG_FILE"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to execute and log commands, exit on error unless specified as 'noncritical'
execute_and_log() {
    local command="$1"
    local error_handling="${2:-critical}"
    log "Executing: $command"
    if ! eval "$command" | tee -a "$LOG_FILE"; then
        log "Error executing: $command"
        if [ "$error_handling" = "critical" ]; then
            log "Critical error encountered. Stopping script."
            exit 1
        else
            log "Non-critical error encountered. Proceeding."
        fi
    else
        log "Successfully executed: $command"
    fi
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    log "This script must be run as root"
    exit 1
fi

log "Starting NVIDIA components removal process."

# Remove NVIDIA driver packages
execute_and_log "sudo apt-get remove --purge '^nvidia-.*' -y"

# Remove CUDA toolkit and other NVIDIA related packages
execute_and_log "sudo apt-get remove --purge '^cuda-.*' '^libnvidia-.*' -y"

# Stop and disable NVIDIA-related services
services=("nvidia-persistenced" "gdm")  # Add other NVIDIA services here if needed
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        execute_and_log "sudo systemctl stop $service"
    fi
    if systemctl is-enabled --quiet "$service"; then
        execute_and_log "sudo systemctl disable $service"
    fi
done

# Unload NVIDIA kernel modules
execute_and_log "sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia"

# Remove NVIDIA container toolkit
execute_and_log "sudo apt-get remove --purge '^nvidia-container.*' -y"

# Remove any residual configuration files
execute_and_log "sudo apt-get autoremove --purge -y"
execute_and_log "sudo apt-get autoclean"

# Update initramfs
execute_and_log "sudo update-initramfs -u"

log "NVIDIA components removal process completed successfully."

# Prompt for reboot
read -p "System needs to be rebooted. Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting the system..."
    execute_and_log "sudo reboot"
else
    log "Please reboot the system manually when convenient."
fi
