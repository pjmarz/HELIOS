#!/bin/bash

# Script to uninstall all NVIDIA related components from Ubuntu

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/purge-nvidia.log"
NVIDIA_DRIVER_DIR="/home/peter/Documents/dev/HELIOS/assets/nvidia"

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

# New function for conditional package removal
remove_package_if_exists() {
    local package_name="$1"
    if is_package_installed "$package_name"; then
        execute_and_log "sudo apt-get remove --purge \"$package_name\" -y"
    else
        log "Package $package_name is not installed, skipping."
    fi
}

log "Starting NVIDIA components removal process."

# Find and uninstall the NVIDIA driver using a wildcard pattern
NVIDIA_DRIVER_PATH=$(find $NVIDIA_DRIVER_DIR -name "NVIDIA-Linux-x86_64-*.run" | head -n 1)
if [ -n "$NVIDIA_DRIVER_PATH" ]; then
    log "Found NVIDIA driver installer: $NVIDIA_DRIVER_PATH"
    log "Uninstalling the NVIDIA driver..."
    execute_and_log "sudo $NVIDIA_DRIVER_PATH --uninstall"
else
    log "No NVIDIA driver installer found in $NVIDIA_DRIVER_DIR"
fi

# Dynamically remove NVIDIA driver packages
execute_and_log "sudo apt-get remove --purge '^nvidia-.*' -y"

# Dynamically remove CUDA toolkit packages
cuda_packages=$(dpkg -l | grep -E 'cuda-|nvidia-cuda' | awk '{print $2}')
for package in $cuda_packages; do
    remove_package_if_exists "$package"
done

# Dynamically remove any other NVIDIA related packages (libraries, encoders, etc.)
nvidia_related_packages=$(dpkg -l | grep -E 'libnvidia-|nvidia-' | awk '{print $2}')
for package in $nvidia_related_packages; do
    remove_package_if_exists "$package"
done

# Stop NVIDIA persistence daemon
if systemctl --all --type service | grep -q nvidia-persistenced; then
    execute_and_log "sudo systemctl stop nvidia-persistenced"
else
    log "nvidia-persistenced service not loaded, skipping."
fi

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

# Remove the contents of NVIDIA download directory
log "Removing NVIDIA download directory contents..."
execute_and_log "rm -rf ${NVIDIA_DRIVER_DIR}/*"

log "System needs to be rebooted. Please reboot the system manually."
