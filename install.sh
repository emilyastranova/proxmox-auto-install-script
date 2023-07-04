#!/bin/bash

# Banner
echo "=== Proxmox VE Installation Script ==="

# Add /usr/sbin to PATH
export PATH=$PATH:/usr/sbin

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
fi

# Check if running pve-kernel
if ! uname -r | grep -q "pve"; then
    # Ask for static IP
    read -p "Enter the desired static IP address: " static_ip

    # Ask for the gateway IP
    read -p "Enter the gateway IP address: " gateway_ip

    # List available Ethernet interfaces
    echo "Available Ethernet interfaces:"
    ip -br link show | awk '{print $1}'
    read -p "Enter the Ethernet interface to use: " interface

    # Generate /etc/network/interfaces entry
    echo "auto lo
    iface lo inet loopback

auto $interface
iface $interface inet static
    address $static_ip
    netmask 255.255.255.0
    gateway $gateway_ip" > /etc/network/interfaces

    echo "Created /etc/network/interfaces entry."

    # Generate hosts file
    echo "127.0.0.1 localhost
$static_ip $(hostname)" > /etc/hosts
    
    # Restart networking service
    echo "Restarting networking service..."
    systemctl restart networking.service

    # Add Proxmox VE apt source
    echo "Adding Proxmox VE apt source..."
    echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

    # Get GPG key
    echo "Getting GPG key..."
    wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg

    # Update and upgrade
    echo "Updating and upgrading..."
    apt update && apt full-upgrade -y

    # Install kernel based on user choice
    read -p "Do you want to install pve-kernel-5.15 or pve-kernel-6.2? (5.15/6.2): " kernel_version
    if [ "$kernel_version" == "6.2" ]; then
        apt install -y pve-kernel-6.2
    else
        apt install -y pve-kernel-5.15
    fi

    # Ask for reboot
    read -p "Proxmox VE kernel installation is complete. A reboot is required before finishing setup. Run this script again after rebooting. Would you like to reboot now? (y/n): " reboot_choice
    if [ "$reboot_choice" == "y" ]; then
        /usr/sbin/reboot
    fi

# If running pve-kernel
else
    echo "Proxmox VE kernel detected. Continuing setup..."

    # Install required packages
    echo "Installing required packages..."

    # Warn user about postfix configuration
    echo "Postfix configuration will be required. If you have a mail server in your network, you should configure postfix as a satellite system. Your existing mail server will then be the relay host which will route the emails sent by Proxmox VE to their final recipient. If you don't know what to enter here, choose local only and leave the system name as is. (most people)."
    read -p "Press enter to continue..."
    apt install -y proxmox-ve postfix open-iscsi

    # Remove linux-image-5.10*
    echo "Removing linux-image-5.10*..."
    apt remove -y linux-image-amd64 'linux-image-5.*'

    # Update GRUB
    echo "Updating GRUB..."
    update-grub

    # Remove os-prober
    read -p "Would you like to remove os-prober? (y/n): " osprober_choice
    if [ "$osprober_choice" == "y" ]; then
        apt remove -y os-prober
    fi

    # Ask if user wants to remove subscription notice
    read -p "Would you like to remove the subscription notice? (y/n): " subscription_choice
    if [ "$subscription_choice" == "y" ]; then
        # Remove subscription notice
        echo "Removing subscription notice..."
        sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
        echo "Subscription notice removed."
    fi

    # Ask user if they want to add the beep startup script
    read -p "Would you like to add the beep startup script? (y/n): " beep_choice
    if [ "$beep_choice" == "y" ]; then
        # Add beep startup script
        apt install beep -y
        echo "[Unit]
Description=Beep after pve-proxy.service has loaded
After=pve-proxy.service

[Service]
Type=oneshot
ExecStart=/usr/bin/beep -f 2000 -l 50 -r 3

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/beep-after-pve-proxy.service
        systemctl daemon-reload
        systemctl enable --now beep-after-pve-proxy.service
        echo "Beep startup script added."
    fi

    # Final reboot
    read -p "Proxmox VE configuration is complete. Would you like to reboot now? (y/n): " reboot_choice
    if [ "$reboot_choice" == "y" ]; then
        reboot
    fi
fi
