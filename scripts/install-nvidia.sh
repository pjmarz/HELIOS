#!/bin/bash

# https://developer.nvidia.com/cuda-downloads
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

# -------------------------------------------------------------------------- #

LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/install-nvidia.log"
NVIDIA_DOWNLOAD_DIR="/home/peter/Documents/dev/HELIOS/assets/nvidia"
LOG_DIR="$(dirname "$LOG_FILE")"

mkdir -p "${NVIDIA_DOWNLOAD_DIR}"
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

is_nouveau_in_use() {
    lsmod | grep -q "^nouveau"
}

if [[ $EUID -ne 0 ]]; then
    log "This script must be run as root"
    exit 1
fi

log "Updating the system..."
execute_and_log "apt-get update && apt-get upgrade -y"

log "Installing necessary tools and kernel headers..."
execute_and_log "apt-get install -y wget build-essential linux-headers-$(uname -r) gcc g++"

if is_nouveau_in_use; then
    log "Disabling the Nouveau driver..."
    echo -e "blacklist nouveau\noptions nouveau modeset=0" | tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null
    execute_and_log "update-initramfs -u"
    log "Nouveau driver disabled. Please reboot and rerun the script."
    exit 1
else
    log "Nouveau driver is not in use, skipping disabling."
fi

log "Installing NVIDIA drivers..."
execute_and_log "apt-get install -y nvidia-driver"

log "Installing nvidia-cuda-toolkit..."
execute_and_log "apt-get install -y nvidia-cuda-toolkit"

log "Setting up the NVIDIA Container Toolkit..."
execute_and_log "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
execute_and_log "curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
execute_and_log "apt-get update"
execute_and_log "apt-get install -y nvidia-container-toolkit"

log "Validating NVIDIA driver installation..."
if ! nvidia-smi | tee -a "$LOG_FILE"; then
    log "NVIDIA driver validation failed. Please check the log file for more details."
    exit 1
else
    log "NVIDIA driver validation successful."
fi

read -p "System needs to be rebooted for changes to take effect. Reboot now? (y/n) " -n 1 -r -t 30
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting the system..."
    execute_and_log "reboot"
else
    log "Please reboot the system manually when convenient."
fi