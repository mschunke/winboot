#!/bin/bash
echo "WINDOWS BOOTABLE USB CREATOR"
echo "============================"
read -p "Please enter the USB disk you want to create as a bootable Windows device (e.g. disk99): " diskName
read -p "Please enter the volume of the mounted Windows ISO file (e.g. CCCOMA_X64FRE_EN-US_DV9): " isoVolume
echo ""
echo "INFORMATION for $diskName"
echo "========================="
echo "WARNING: This will erase all data on the disk $diskName"
diskutil info $diskName | grep -E 'Removable Media|Disk Size|Device Name|Protocol'
echo ""
echo "INFORMATION FOR $isoVolume"
if [ -d "/Volumes/$isoVolume" ]; then
    if [ -f "/Volumes/$isoVolume/sources/install.wim" ]; then
        fileSize=$(stat -f%z "/Volumes/$isoVolume/sources/install.wim")
        echo "Filesize for install.wim: $fileSize bytes"
        if [ $fileSize -gt 4294967296 ]; then
            requiresWimlib=true
        else
            requiresWimlib=false
        fi
    else
        echo "File /Volumes/$isoVolume/sources/install.wim not found. Is this a Windows installation ISO image?"
        exit 1
    fi
else
    echo "Volume /Volumes/$isoVolume not found."
    exit 1
fi

if [ $requiresWimlib = true ]; then
    if ! command -v wimlib-imagex &> /dev/null; then
        echo "This ISO image requires wimlib to create a bootable USB device."
        echo "Please install wimlib using Homebrew with the following command:"
        echo "brew install wimlib"
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
diskutil eraseDisk MS-DOS "WINBOOT" MBR $diskName
echo ""
echo "Copying files from $isoVolume to $diskName..."
if [ $requiresWimlib = true ]; then
    rsync -avh --progress --exclude=sources/install.wim /Volumes/$isoVolume/ /Volumes/WINBOOT
    wimlib-imagex split "/Volumes/$isoVolume/sources/install.wim" /Volumes/WINBOOT/sources/install.swm 3800
else
    rsync -avh --progress "/Volumes/$isoVolume/" /Volumes/WINBOOT
fi
echo ""
echo "USB device $diskName is now bootable with Windows."
echo "If desired, please unmount $isoVolume and uninstall Wimlib."
echo "To uninstall Wimlib, run 'brew uninstall wimlib'."
echo "To unmount $isoVolume, run 'diskutil unmount /Volumes/$isoVolume'."
