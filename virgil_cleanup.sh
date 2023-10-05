#!/bin/bash

# Function to check the status of the last command and display an error
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error with command: $1"
    fi
}

# Update Ubuntu Pro services
sudo ua refresh
check_status "sudo ua refresh"

# Update package lists
sudo apt update
check_status "sudo apt update"

# Upgrade installed packages
sudo apt upgrade -y
check_status "sudo apt upgrade"

# Force upgrade of packages that are held back
UPGRADES=$(sudo apt list --upgradable 2>/dev/null | grep -v Listing | grep upgradable | awk -F/ '{print $1}')
if [ -n "$UPGRADES" ]; then
    sudo apt install -y $UPGRADES
    check_status "sudo apt install specific packages"
fi

# Remove unused packages and dependencies
sudo apt autoremove -y
check_status "sudo apt autoremove"

# Clean the package cache
sudo apt clean
check_status "sudo apt clean"

# Remove old kernels (if any)
sudo apt --purge autoremove -y
check_status "sudo apt --purge autoremove"

# Remove orphaned packages
sudo deborphan | xargs sudo apt-get -y remove --purge
check_status "sudo deborphan | xargs sudo apt-get remove"

# Remove old configuration files
OLD_CONFIGS=$(sudo dpkg --list | grep '^rc' | awk '{print $2}')
if [ -n "$OLD_CONFIGS" ]; then
    echo "$OLD_CONFIGS" | xargs sudo dpkg --purge
    check_status "sudo dpkg --purge old configs"
fi

# Clear systemd journal logs
sudo journalctl --vacuum-time=3d
check_status "sudo journalctl --vacuum-time=3d"

# Clear the thumbnail cache for the current user
rm -rf ~/.cache/thumbnails/*
check_status "rm -rf ~/.cache/thumbnails/*"

# Clear the trash
rm -rf ~/.local/share/Trash/*
check_status "rm -rf ~/.local/share/Trash/*"

echo "System cleanup complete!"
