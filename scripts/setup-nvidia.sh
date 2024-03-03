#!/bin/bash

# https://developer.nvidia.com/cuda-downloads
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

# -------------------------------------------------------------------------- #

# Define variables for versions and URLs
CUDA_VERSION="cuda-toolkit-12-3"
NVIDIA_DRIVER_VERSION="550.54.14"
NVIDIA_DRIVER_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"
CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb"

# Define the directory for NVIDIA related downloads
NVIDIA_DOWNLOAD_DIR="$HOME/Documents/dev/HELIOS/assets/nvidia"

# Log file path
LOG_FILE="$HOME/Documents/dev/HELIOS/script_logs/nvidia-setup.log"

# Ensure NVIDIA download directory exists
mkdir -p "${NVIDIA_DOWNLOAD_DIR}"

# Clear the log file at the beginning of the script
: > "$LOG_FILE"

# Function to log a message with a timestamp
log() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${msg}" | tee -a "$LOG_FILE"
}

# Function to execute and log commands
execute_and_log() {
    local command="$*"
    log "Executing: $command"
    if ! eval "$command"; then
        log "Error executing: $command"
        exit 1
    fi
}

log "Updating the system..."
execute_and_log "sudo apt-get update && sudo apt-get upgrade -y"

log "Installing necessary tools and kernel headers..."
execute_and_log "sudo apt-get install -y wget build-essential linux-headers-$(uname -r) gcc-12 g++-12"

log "Ensuring GCC-12 is the default compiler..."
execute_and_log "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 60 --slave /usr/bin/g++ g++ /usr/bin/g++-12"
execute_and_log "sudo update-alternatives --set gcc /usr/bin/gcc-12"

log "Disabling the Nouveau driver..."
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null
execute_and_log "sudo update-initramfs -u"

log "Downloading and installing the CUDA toolkit keyring..."
execute_and_log "wget -q ${CUDA_KEYRING_URL} -O ${NVIDIA_DOWNLOAD_DIR}/cuda-keyring.deb"
execute_and_log "sudo dpkg -i ${NVIDIA_DOWNLOAD_DIR}/cuda-keyring.deb"

log "Installing the CUDA Toolkit..."
execute_and_log "sudo apt-get update && sudo apt-get install -y ${CUDA_VERSION}"

log "Stopping graphical session to free up NVIDIA modules..."
DISPLAY_MANAGER=$(basename "$(cat /etc/X11/default-display-manager)")
execute_and_log "sudo systemctl stop ${DISPLAY_MANAGER}"

# Check and unload NVIDIA kernel modules if they are loaded
log "Checking for loaded NVIDIA kernel modules..."
if lsmod | grep -qE "nvidia_drm|nvidia_modeset|nvidia_uvm|nvidia"; then
    log "NVIDIA kernel modules are loaded, attempting to unload..."
    execute_and_log "sudo modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia"
else
    log "No NVIDIA kernel modules are loaded."
fi

log "Downloading the NVIDIA driver..."
execute_and_log "wget -q ${NVIDIA_DRIVER_URL} -O ${NVIDIA_DOWNLOAD_DIR}/NVIDIA-Driver.run"
execute_and_log "chmod +x ${NVIDIA_DOWNLOAD_DIR}/NVIDIA-Driver.run"

log "Installing the NVIDIA driver..."
# Explicitly setting the compiler to GCC-12 for NVIDIA driver installation
export CC=/usr/bin/gcc-12
execute_and_log "sudo ${NVIDIA_DOWNLOAD_DIR}/NVIDIA-Driver.run --dkms --ui=none --no-questions --silent"
unset CC # Unsetting CC to avoid affecting subsequent commands

log "Setting up the NVIDIA Container Toolkit..."
execute_and_log "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
execute_and_log "curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null"
execute_and_log "sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"

log "System needs to be rebooted for changes to take effect. Please reboot the system manually."
