#! /usr/bin/env sh

# Wipe the selected disk
correct=$(dialog --stdout --menu "We will wipe all data on $INSTALL_DEVICE. THIS CANNOT BE UNDONE! Is $INSTALL_DEVICE correct?" 0 0 0 N No Y Yes)
[[ "$correct" == "Y" ]] || ( echo "Aborting due to user interaction..."; exit 1 )

echo "Erasing old partition scheme from $INSTALL_DEVICE ..."
[ "$DEBUG" == "true" ] || echo "wipefs ...."
#wipefs --all --backup $INSTALL_DEVICE
echo "Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"



# Create one single partition
echo "Converting disk to GPT format"
#sgdisk --mbrtogpt $INSTALL_DEVICE
echo "We now create one partition, filling the whole device $INSTALL_DEVICE . This will be encrypted later."
#sgdisk --new=1:0:0 $INSTALL_DEVICE



# Check boot mode is UEFI and select EFI partition
efi_partition=""

2>&1 ls /sys/Firmware/efi/efivars > /dev/null
if [ "$?" == "0" ]
then
	echo "Checking for existing EFI boot partition ..."
	efi_partition=$(fdisk --list --output device,type $USB_KEY | awk '/EFI/ { print $1 }')
	if [ "$efi_partition" == "" ]
	then
		# Wipe the selected disk
		correct=$(dialog --stdout --menu "We did not found an existing EFI partition on the usb key $USB_KEY! We will wipe all data on it $USB_KEY. THIS CANNOT BE UNDONE! Is $USB_KEY correct?" 0 0 0 N No Y Yes)
		[[ "$correct" == "Y" ]] || ( echo "Aborting due to user interaction..."; exit 1 )

		echo "Erasing old partition scheme from $USB_KEY ..."
		[ "$DEBUG" == "true" ] || echo "wipefs ...."
		#wipefs --all --backup $USB_KEY
		echo "Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"

		#sgdisk --zap-all $USB_KEY
		#sgdisk --mbrtogpt $USB_KEY

		#sgdisk --new=0:0:512M --type-code 0:EF00 $USB_KEY
		#mkfs.fat -F32 $EFI_PARTITION

		#sgdisk --new=0:0:0 --type-code 0:8300 $USB_KEY
		#cryptsetup luksFormat $BOOT_PARTITION
	fi
fi

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
