#!/bin/bash

LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/update-nvidia.log"
mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

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

if [[ $EUID -ne 0 ]]; then
   log "This script must be run as root" 
   exit 1
fi

log "Updating package list..."
execute_and_log "sudo apt-get update"

log "Finding NVIDIA-related packages..."
nvidia_packages=$(dpkg -l | grep -i nvidia | awk '{print $2}' | tr '\n' ' ')
if [[ -z "$nvidia_packages" ]]; then
    log "No NVIDIA packages found to upgrade."
else
    log "Upgrading NVIDIA-related packages..."
    execute_and_log "sudo apt-get dist-upgrade -y"
fi

log "Cleaning up unnecessary packages..."
execute_and_log "sudo apt-get autoremove -y"

log "All NVIDIA-related packages have been updated."
