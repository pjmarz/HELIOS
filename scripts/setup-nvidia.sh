#!/bin/bash

# https://developer.nvidia.com/cuda-downloads
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.2.2-base-ubuntu22.04 nvidia-smi

# -------------------------------------------------------------------------- #

# Script to set up NVIDIA on Ubuntu 22.04

echo "Updating the system..."
sudo apt-get update
sudo apt-get upgrade -y

echo "Installing necessary tools and kernel headers..."
sudo apt-get install -y wget build-essential linux-headers-$(uname -r)

echo "Installing libnvidia encode components..."
sudo apt-get install libnvidia-encode-535

echo "Disabling the Nouveau driver..."
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

echo "Downloading and installing the CUDA toolkit keyring..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

echo "Installing the CUDA Toolkit..."
sudo apt-get update
sudo apt-get install -y cuda-toolkit-12-3

echo "Downloading the NVIDIA driver..."
wget -P ./ https://us.download.nvidia.com/XFree86/Linux-x86_64/535.146.02/NVIDIA-Linux-x86_64-535.146.02.run
chmod +x ./NVIDIA-Linux-x86_64-535.146.02.run

echo "Installing the NVIDIA driver..."
sudo ./NVIDIA-Linux-x86_64-535.146.02.run

echo "Setting up the NVIDIA Container Toolkit..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

echo "Rebooting the system..."
sudo reboot
