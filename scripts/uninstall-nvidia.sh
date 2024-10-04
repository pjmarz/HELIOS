#!/bin/bash

LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/uninstall-nvidia.log"
LOG_DIR="$(dirname "$LOG_FILE")"

mkdir -p "$LOG_DIR"
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

log "Starting NVIDIA components removal process."

execute_and_log "apt-get remove --purge '^nvidia-.*' -y"
execute_and_log "apt-get remove --purge '^cuda-.*' '^libnvidia-.*' -y"

services=("nvidia-persistenced" "gdm")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        execute_and_log "systemctl stop $service"
    fi
    if systemctl is-enabled --quiet "$service"; then
        execute_and_log "systemctl disable $service"
    fi
done

execute_and_log "rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia"
execute_and_log "apt-get remove --purge '^nvidia-container.*' -y"
execute_and_log "apt-get autoremove --purge -y"
execute_and_log "apt-get autoclean"
execute_and_log "update-initramfs -u"

log "NVIDIA components removal process completed successfully."

read -p "System needs to be rebooted. Reboot now? (y/n) " -n 1 -r -t 30
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting the system..."
    execute_and_log "reboot"
else
    log "Please reboot the system manually when convenient."
fi