#!/bin/bash
echo "WINDOWS BOOTABLE USB CREATOR"
echo "============================"read -p "Please enter the USB disk you want to create as a bootable Windows device (e.g. /dev/sdX): " diskName
read -p "Please enter the volume of the mounted Windows ISO file (e.g. CCCOMA_X64FRE_EN-US_DV9): " isoVolume
echo ""
echo "INFORMATION for $diskName"
echo "========================="
echo "WARNING: This will erase all data on the disk $diskName"
lsblk -o NAME,SIZE,MODEL | grep $(basename $diskName)
echo ""
echo "INFORMATION FOR $isoVolume"
if [ -d "/mnt/$isoVolume" ]; then
    if [ -f "/mnt/$isoVolume/sources/install.wim" ]; then
        fileSize=$(stat -c%s "/mnt/$isoVolume/sources/install.wim")
        echo "Filesize for install.wim: $fileSize bytes"
        if [ $fileSize -gt 4294967296 ]; then
            requiresWimlib=true
        else
            requiresWimlib=false
        fi
    else
        echo "File /mnt/$isoVolume/sources/install.wim not found. Is this a Windows installation ISO image?"
        exit 1
    fi
else
    echo "Volume /mnt/$isoVolume not found."
    exit 1
fi

if [ $requiresWimlib = true ]; then
    if ! command -v wimlib-imagex &> /dev/null; then
        echo "This ISO image requires wimlib to create a bootable USB device."
        echo "Please install wimlib using your package manager (e.g., apt, yum) with the following command:"
        echo "sudo apt install wimtools"
        echo "Then run this script again."
        exit 1
    else
        echo "wimlib is installed, proceeding with the creation of the bootable USB device."
    fi
fi

echo ""
echo "Is the above information correct?"
read -p "(yes/n): " confirm
if [ "$confirm" != "yes" ]; then
    echo '"yes" not entered. Exiting...'
    exit 1
fi

echo ""
echo "Formatting $diskName as FAT32 with MBR partition scheme..."
sudo mkfs.vfat -F 32 -I $diskName
sudo parted $diskName mklabel msdos
echo ""
echo "Copying files from $isoVolume to $diskName..."
sudo mount $diskName /mnt/usb
if [ $requiresWimlib = true ]; then
    sudo rsync -avh --progress --exclude=sources/install.wim /mnt/$isoVolume/ /mnt/usb
    sudo wimlib-imagex split "/mnt/$isoVolume/sources/install.wim" /mnt/usb/sources/install.swm 3800
else
    sudo rsync -avh --progress "/mnt/$isoVolume/" /mnt/usb
fi
sudo umount /mnt/usb
echo ""
echo "USB device $diskName is now bootable with Windows."
echo "If desired, please unmount $isoVolume and uninstall Wimlib."
echo "To uninstall Wimlib, run 'sudo apt remove wimtools'."
echo "To unmount $isoVolume, run 'sudo umount /mnt/$isoVolume'."
