#! /usr/bin/env sh

umount /mnt/boot
umount /mnt/efi
umount /mnt

vgchange -a n
cryptsetup luksClose $LUKS_BOOT_DEVICE_NAME
cryptsetup luksClose $LUKS_DEVICE_NAME

echo "All done!"
read -p "Remove the USB stick and press [Enter] to reboot to your new system..."
reboot

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
