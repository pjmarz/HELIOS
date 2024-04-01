#!/bin/bash

# Script to uninstall all NVIDIA related components from Ubuntu

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/purge-nvidia.log"
NVIDIA_DRIVER_DIR="/home/peter/Documents/dev/HELIOS/assets/nvidia"
NVIDIA_DRIVER_PATH="${NVIDIA_DRIVER_DIR}/NVIDIA-Linux-x86_64-*.run"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to execute a command, log its action, and check for errors
execute_and_log() {
    local command="$@"
    log "Executing: $command"
    if eval $command | tee -a "$LOG_FILE"; then
        log "Successfully executed: $command"
    else
        log "Error executing: $command"
        exit 1 # Exit script if an error occurs
    fi
}

# Function to unload kernel modules
unload_kernel_modules() {
    local modules=("$@")
    for module in "${modules[@]}"; do
        if lsmod | grep -q "^${module}"; then
            log "Module ${module} is loaded, attempting to unload..."
            execute_and_log "sudo rmmod ${module}"
        else
            log "Module ${module} is not currently loaded, skipping."
        fi
    done
}

log "Starting NVIDIA components removal process."

# Uninstall the NVIDIA driver
if [ -f "$NVIDIA_DRIVER_PATH" ]; then
    log "Found NVIDIA driver installer: $NVIDIA_DRIVER_PATH"
    log "Uninstalling the NVIDIA driver..."
    execute_and_log "sudo $NVIDIA_DRIVER_PATH --uninstall"
else
    log "No NVIDIA driver installer found in $NVIDIA_DRIVER_DIR"
fi

# Remove NVIDIA driver packages
execute_and_log "sudo apt-get remove --purge '^nvidia-.*' -y"

# Remove CUDA toolkit and other NVIDIA related packages
packages_to_remove=$(dpkg -l | grep -E 'cuda-|nvidia-cuda|libnvidia-|nvidia-' | awk '{print $2}')
if [ -n "$packages_to_remove" ]; then
    execute_and_log "sudo apt-get remove --purge $packages_to_remove -y"
else
    log "No CUDA toolkit or other NVIDIA related packages found."
fi

# Stop NVIDIA persistence daemon
if systemctl --all --type service | grep -q nvidia-persistenced; then
    execute_and_log "sudo systemctl stop nvidia-persistenced"
else
    log "nvidia-persistenced service not loaded, skipping."
fi

# Stop GDM to release the NVIDIA kernel modules
execute_and_log "sudo systemctl stop gdm"

# Unload NVIDIA kernel modules
unload_kernel_modules nvidia_drm nvidia_modeset nvidia_uvm nvidia

# Remove NVIDIA container toolkit
execute_and_log "sudo apt-get remove --purge '^nvidia-container.*' -y"

# Remove any other residual configuration files
execute_and_log "sudo apt-get autoremove --purge -y"
execute_and_log "sudo apt-get autoclean"

# Update initramfs
execute_and_log "sudo update-initramfs -u"

# Remove the contents of NVIDIA download directory
log "Removing NVIDIA download directory contents..."
execute_and_log "sudo rm -rf ${NVIDIA_DRIVER_DIR}/*"

# Prompt for reboot
read -p "System needs to be rebooted. Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting the system..."
    execute_and_log "sudo reboot"
else
    log "Please reboot the system manually when convenient."
fi
