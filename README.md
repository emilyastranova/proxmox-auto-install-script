# Proxmox Auto-Install Script

![License](https://img.shields.io/badge/License-GNU-blue.svg)
![Debian version](https://img.shields.io/badge/Debian-11-blue)
![pve-kernel](https://img.shields.io/badge/pve--kernel-5.15%2C%206.2-important)
![pve-version](https://img.shields.io/badge/Tested%20on%20PVE-7.4--3-green)

This repository contains a convenient auto-install script for Proxmox VE, designed to streamline the installation process on Debian-based systems. The script automates several steps, including network configuration, repository setup, kernel installation, and optional package installation.

## Prerequisites

Before using this script, ensure that you have the following prerequisites installed:

- Git: `sudo apt install git -y`

## Installation

To install Proxmox VE using this auto-install script, follow these steps:

1. Clone this repository using Git:
   ```shell
   git clone https://github.com/tyleraharrison/proxmox-auto-install-script.git
   ```

2. Change into the cloned directory:
   ```shell
   cd proxmox-auto-install-script
   ```

3. Make the `install.sh` script executable:
   ```shell
   chmod +x install.sh
   ```

4. Switch to the root user:
   ```shell
   su
   ```

5. Run the script:
   ```shell
   ./install.sh
   ```

The script will guide you through the installation process, prompting for necessary information and performing various configuration steps.

## License

This project is licensed under the terms of the GNU General Public License (GNU GPL). See the [LICENSE](LICENSE) file for more details.

## Disclaimer

Please note that running scripts as root can have significant consequences on your system. Ensure that you understand the script's actions and review it carefully before executing it. It is recommended to have backups and test the script in a controlled environment before running it on a production system.

## Contributions

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

## Author

This Proxmox Auto-Install Script is maintained by [Tyler Harrison](https://github.com/tyleraharrison).

## Acknowledgments

This script is inspired by the need for a simplified and automated installation process for Proxmox VE. Special thanks to the Proxmox community for their support and valuable feedback.

If you encounter any issues while using this script, please report them on the [GitHub Issues](https://github.com/tyleraharrison/proxmox-auto-install-script/issues) page.
