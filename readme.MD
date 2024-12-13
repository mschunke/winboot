# Create a Windows 10/11 Installation bootable USB on Mac/Linux

This script allows you to create a bootable USB drive from a Windows installation ISO disk iamge.

## Contents of this repo:

- `readme.MD` This file
- `winboot-linux.sh` The Linux version of the script
- `winboot-mac.sh` The Mac version of the script

## How to use

### Before you start

Make sure you have already downloaded a copy of a Windows bootable installation disk ISO image. If you don't have one, you can download form Microsoft at: https://www.microsoft.com/en-us/software-download/windows11

**For MAC only**: It likely that you're going to need Wimlib to complete the process. We recommend using [Homebrew](https://brew.sh/) for this. You'll be notified if the installation is required, you don't need to run any pre-checks.

### 1. Mount the ISO image

Mount the ISO image so it's available as a storage device on the system. Take note of the disk volume (usually something like _CCCOMA_X64FRE_EN-US_DV9_, on a Mac).

### 2. Insert the USB drive

For Windows 10 or 11, this should be at least an 8gb drive. All information on this drive will be permanently erased. Note it's path on the system (usually _disk123_ on a Mac, or _usb_ on Linux).

### 2. Make the script executable

- **MAC**: Run `chmod +x ./winboot-mac.sh`
- **LINUX**: Run `chmod +x ./winboot-linux.sh`

### 3. Run the script

On the terminal type: `./winboot-mac.sh` or `./winboot-linux.sh` according to your system.

Enter both the USB disk path and the ISO volume name when requested.

Confirm that the printed information is correct and confirm.

Just relax and wait for the process to complete.

## Contributing

If you want to help to improve this script, just fork and open a PR. All help is appreciated. Thank you.

## MIT License

2024 by Murilo Schünke
