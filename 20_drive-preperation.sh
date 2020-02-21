#! /usr/bin/env sh

DIALOG_STEP_TITLE="Drive preperation"
DIALOG_SUBSTEP_TITLE="Wipe disk"
PROGRESS_PERCENTAGE=20

# Wipe the selected disk
correct=$(show_yesno_menu "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We will wipe all data on $INSTALL_DEVICE. THIS CANNOT BE UNDONE! Is $INSTALL_DEVICE correct?")
[[ "$correct" == "Y" ]] || ( echo "Aborting due to user interaction..."; exit 1 )

if [ "$DEBUG" == "true" ] 
then
  show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
else
    wipefs --all --backup $INSTALL_DEVICE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Erasing old partition scheme from $INSTALL_DEVICE ..."
  show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Wipe done. Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"
fi



DIALOG_SUBSTEP_TITLE="Partitioning"
if [ "$DEBUG" == "true" ] 
then
  show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
else
  sgdisk --mbrtogpt $INSTALL_DEVICE | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Converting disk to GPT format"
  sgdisk --new=1:0:0 $INSTALL_DEVICE | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We now create one partition, filling the whole device $INSTALL_DEVICE . This will be encrypted later."
fi



DIALOG_SUBSTEP_TITLE="Searching existing boot and EFI partitions"
show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We will now search for existing partitions on the usb device."

efi_partition=""
2>&1 ls /sys/Firmware/efi/efivars > /dev/null
if [ "$?" == "0" ]
then
	efi_partition=$(fdisk --list --output device,type $USB_KEY | awk '/EFI/ { print $1 }')
	if [ "$efi_partition" == "" ]
	then
    DIALOG_SUBSTEP_TITLE="Creating boot and EFI partitions"

		# Wipe the selected disk
		correct=$(show_yesno_menu "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We did not found an existing EFI partition on the usb key $USB_KEY! We will wipe all data on it $USB_KEY. THIS CANNOT BE UNDONE! Is $USB_KEY correct?")
		[[ "$correct" == "Y" ]] || exit 1

    if [ "$DEBUG" == "true" ] 
    then
      show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
    else
      wipefs --all --backup $USB_KEY | \
        show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Erasing old partition scheme from $USB_KEY ..."
      show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Wipe done. Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"

      while IFS= read -r command; do
        echo "$command" | \
          show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Executing $command ..."
      done <<< $( cat << EOF
        sgdisk --zap-all $USB_KEY
        sgdisk --mbrtogpt $USB_KEY

        sgdisk --new=0:0:512M --type-code 0:EF00 $USB_KEY
        mkfs.fat -F32 $EFI_PARTITION

        sgdisk --new=0:0:0 --type-code 0:8300 $USB_KEY
        echo "$ENCYPTION_PASSPHRASE" > ~/encryption.pass
        cryptsetup luksFormat $BOOT_PARTITION ~/encryption.pass
        rm ~/.encrpytion.pass
EOF
)
	fi
fi

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
