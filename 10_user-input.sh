#! /usr/bin/env sh

#####  Get some user input for variable data  #####

HOSTNAME=$(dialog --stdout --inputbox "Enter hostname / name of your computer" 0 0) || exit 1
clear
: ${hostname:?"hostname cannot be empty"}


USERNAME=$(dialog --stdout --inputbox "Enter admin username" 0 0) || exit 1
clear
: ${user:?"user cannot be empty"}


USER_PASSWORD=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
clear
: ${password:?"password cannot be empty"}
password_check=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
clear
[[ "$USER_PASSWORD" == "$password_check" ]] || ( echo "Passwords did not match"; exit 1; )


devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
INSTALL_DEVICE=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
ENCRYPTION_PARTITION="$(ls ${device}* | grep -E "^${device}p?1$")"
clear


devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
USB_KEY=$(dialog --stdout --menu "Select the usb key device to store the LUKS header and boot partition on." 0 0 0 ${devicelist}) || exit 1
EFI_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?1$")"
BOOT_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?2$")"
clear
