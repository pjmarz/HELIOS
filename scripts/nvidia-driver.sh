#!/bin/bash

# https://github.com/NVIDIA/nvidia-container-toolkit
# https://www.nvidia.com/en-us/drivers/unix/
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# sudo ./NVIDIA-Linux-XXXXXXX.run --uninstall

# https://old.reddit.com/r/PleX/comments/12ikwup/plex_docker_hardware_transcoding_issue/jg2l7lc/

# docker run --rm --gpus all nvidia/cuda:12.2.2-base-ubuntu22.04 nvidia-smi

sudo apt-get install -y wget
wget -P ./ https://us.download.nvidia.com/XFree86/Linux-x86_64/535.146.02/NVIDIA-Linux-x86_64-535.146.02.run

chmod +x ./NVIDIA-Linux-x86_64-535.146.02.run

sudo ./NVIDIA-Linux-x86_64-535.146.02.run