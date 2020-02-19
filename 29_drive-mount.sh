#! /usr/bin/env sh

echo "Mounting the root volume ..."
mount /dev/mapper/main-root /mnt

echo "Mounting the EFI partition from the usb stick $EFI_PARTITION ..."
mkdir /mnt/efi
mount $EFI_PARTITION /mnt/efi

echo "Mounting the boot partition from the usb stick $BOOT_PARTITION ..."
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot

echo "Activating the swap volume ..."
swapon /dev/mapper/main-swap

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
