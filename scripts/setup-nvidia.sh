#!/bin/bash

# https://developer.nvidia.com/cuda-downloads
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

# -------------------------------------------------------------------------- #

# Define the log file
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/nvidia-setup.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to log a message with a timestamp
log() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Updating the system..."
sudo apt-get update
sudo apt-get upgrade -y

log "Installing necessary tools and kernel headers..."
sudo apt-get install -y wget build-essential linux-headers-$(uname -r)

log "Disabling the Nouveau driver..."
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

log "Downloading and installing the CUDA toolkit keyring..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

log "Installing the CUDA Toolkit..."
sudo apt-get update
sudo apt-get install -y cuda-toolkit-12-3

log "Stopping graphical session to free up NVIDIA modules..."
sudo systemctl stop gdm # Replace 'gdm' with your display manager if different

log "Downloading the NVIDIA driver..."
wget -P ./ https://us.download.nvidia.com/XFree86/Linux-x86_64/550.54.14/NVIDIA-Linux-x86_64-550.54.14.run
chmod +x ./NVIDIA-Linux-x86_64-550.54.14.run

log "Installing the NVIDIA driver..."
sudo ./NVIDIA-Linux-x86_64-550.54.14.run

log "Setting up the NVIDIA Container Toolkit..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

log "System needs to be rebooted for changes to take effect. Please reboot the system manually."
