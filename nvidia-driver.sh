#!/bin/bash

# https://www.nvidia.com/en-us/drivers/unix/

sudo apt-get install -y wget
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/535.113.01/NVIDIA-Linux-x86_64-535.113.01.run

chmod +x NVIDIA-Linux-x86_64-535.113.01.run

sudo ./NVIDIA-Linux-x86_64-535.113.01.run