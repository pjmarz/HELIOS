#!/bin/bash

# Script to uninstall all NVIDIA related components from Ubuntu 22.04

echo "Removing NVIDIA drivers..."
sudo apt-get remove --purge '^nvidia-.*'

echo "Removing CUDA Toolkit and libnvidia encode components..."
sudo apt-get remove --purge cuda-toolkit-12-3 libnvidia-encode-535

echo "Stopping any NVIDIA services..."
sudo systemctl stop nvidia-persistenced

echo "Unloading NVIDIA kernel modules..."
sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia

echo "Removing NVIDIA Container Toolkit..."
sudo apt-get remove --purge nvidia-container-toolkit

echo "Removing NVIDIA CUDA toolkit keyring..."
sudo apt-get remove --purge cuda-keyring

echo "Re-enabling Nouveau driver (if previously disabled)..."
sudo rm /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

echo "Removing unnecessary packages and cleaning up..."
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Rebooting the system..."
sudo reboot
