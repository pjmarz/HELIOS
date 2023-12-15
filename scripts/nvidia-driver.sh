#!/bin/bash

# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# sudo ./NVIDIA-Linux-XXXXXXX.run --uninstall

sudo apt-get install -y wget
wget -P ./ https://us.download.nvidia.com/XFree86/Linux-x86_64/535.146.02/NVIDIA-Linux-x86_64-535.146.02.run

chmod +x ./NVIDIA-Linux-x86_64-535.146.02.run

sudo ./NVIDIA-Linux-x86_64-535.146.02.run