#! /usr/bin/env sh

umount /mnt/boot
umount /mnt

echo "All done!"
read -p "Remove the USB stick and press [Enter] to reboot to your new system..."
reboot
