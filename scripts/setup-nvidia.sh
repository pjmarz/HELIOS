#!/bin/bash

# https://developer.nvidia.com/cuda-downloads
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

# -------------------------------------------------------------------------- #

# Define variables for logs and download directories
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/setup-nvidia.log"
NVIDIA_DOWNLOAD_DIR="/home/peter/Documents/dev/HELIOS/assets/nvidia"

# Ensure NVIDIA download directory exists
mkdir -p "${NVIDIA_DOWNLOAD_DIR}"

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
    if ! eval "$command"; then
        log "Error executing: $command"
        if [ "$error_handling" = "critical" ]; then
            log "Critical error encountered. Stopping script."
            exit 1
        else
            log "Non-critical error encountered. Proceeding."
        fi
    fi
}

log "Updating the system..."
execute_and_log "sudo apt-get update && sudo apt-get upgrade -y"

log "Installing necessary tools and kernel headers..."
execute_and_log "sudo apt-get install -y wget build-essential linux-headers-$(uname -r) gcc g++"

log "Disabling the Nouveau driver..."
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null
execute_and_log "sudo update-initramfs -u"

log "Downloading and installing the latest NVIDIA driver..."
NVIDIA_DRIVER_VERSION="550.54.14"  # Manually update this version if necessary
NVIDIA_DRIVER_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"
# Navigate to NVIDIA download directory and download the driver with its original name
cd "${NVIDIA_DOWNLOAD_DIR}" && execute_and_log "wget -q ${NVIDIA_DRIVER_URL}"
# Find the downloaded driver file
NVIDIA_DRIVER_FILE=$(ls | grep "NVIDIA-Linux-x86_64-.*.run")
execute_and_log "chmod +x ${NVIDIA_DRIVER_FILE}"
execute_and_log "sudo ./${NVIDIA_DRIVER_FILE} --dkms --ui=none --no-questions --silent"

log "Installing nvidia-cuda-toolkit..."
execute_and_log "sudo apt-get install -y nvidia-cuda-toolkit"

log "Setting up the NVIDIA Container Toolkit..."
execute_and_log "distribution=\$(. /etc/os-release;echo \$ID\$VERSION_ID) && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
execute_and_log "curl -s -L https://nvidia.github.io/nvidia-docker/\$distribution/nvidia-docker.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null"
execute_and_log "sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"

log "System needs to be rebooted for changes to take effect. Please reboot the system manually."
