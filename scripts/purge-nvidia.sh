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

# Function to check if a package is installed
is_package_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to execute a command, log its action, and check for errors
execute_and_log() {
    local command="$@"
    log "Executing: $command"
    if eval $command; then
        log "Successfully executed: $command"
    else
        log "Error executing: $command"
        exit 1 # Exit script if an error occurs
    fi
}

# Function to check and unload a module if it is loaded
unload_module_if_loaded() {
    local module="$1"
    if lsmod | grep -q "^${module}"; then
        log "Module ${module} is loaded, attempting to unload..."
        execute_and_log "sudo rmmod ${module}"
    else
        log "Module ${module} is not currently loaded, skipping."
    fi
}

log "Starting NVIDIA components removal process."

# Dynamically remove NVIDIA driver packages
execute_and_log "sudo apt-get remove --purge '^nvidia-.*' -y"

# Dynamically remove CUDA toolkit packages
cuda_packages=$(dpkg -l | grep -E 'cuda-|nvidia-cuda' | awk '{print $2}')
for package in $cuda_packages; do
    if is_package_installed "$package"; then
        execute_and_log "sudo apt-get remove --purge \"$package\" -y"
    else
        log "Package $package is not installed, skipping."
    fi
done

# Dynamically remove any other NVIDIA related packages (libraries, encoders, etc.)
nvidia_related_packages=$(dpkg -l | grep -E 'libnvidia-|nvidia-' | awk '{print $2}')
for package in $nvidia_related_packages; do
    if is_package_installed "$package"; then
        execute_and_log "sudo apt-get remove --purge \"$package\" -y"
    else
        log "Package $package is not installed, skipping."
    fi
done

# Stop NVIDIA persistence daemon
execute_and_log "sudo systemctl stop nvidia-persistenced"

# Stop GDM to release the NVIDIA kernel modules
execute_and_log "sudo systemctl stop gdm"

# Attempt to remove the NVIDIA kernel modules if they are loaded
log "Attempting to remove NVIDIA kernel modules..."
unload_module_if_loaded nvidia_drm
unload_module_if_loaded nvidia_modeset
unload_module_if_loaded nvidia_uvm
unload_module_if_loaded nvidia

# Remove NVIDIA container toolkit, if installed
execute_and_log "sudo apt-get remove --purge '^nvidia-container.*' -y"

# Remove any other residual configuration files
execute_and_log "sudo apt-get autoremove -y"
execute_and_log "sudo apt-get autoclean"

# Update initramfs
execute_and_log "sudo update-initramfs -u"

log "System needs to be rebooted. Please reboot the system manually."
