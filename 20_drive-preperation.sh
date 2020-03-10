#! /usr/bin/env sh

DIALOG_STEP_TITLE="Drive preperation"
PROGRESS_PERCENTAGE=20

wipe_main_disk() {
  DIALOG_SUBSTEP_TITLE="Wipe disk"

  show_yesno_menu "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We will wipe all data on $INSTALL_DEVICE. THIS CANNOT BE UNDONE! Is $INSTALL_DEVICE correct?"
  if [[ "$?" != "0" ]] 
  then
    echo "Aborting due to user interaction..." 
    exit 1
  fi

  if [ "$DEBUG" == "true" ] 
  then
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
  else
    wipefs --all --backup $INSTALL_DEVICE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Erasing old partition scheme from $INSTALL_DEVICE ..."
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Wipe done. Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"
  fi
}


partition_usb() {
  DIALOG_SUBSTEP_TITLE="Creating boot and EFI partitions"

  # Wipe the selected disk
  show_yesno_menu "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We did not found an existing EFI partition on the usb key $USB_KEY! We will wipe all data on it $USB_KEY. THIS CANNOT BE UNDONE! Is $USB_KEY correct?"
  if [[ "$?" != "0" ]] 
  then
    echo "Aborting due to user interaction..."
    exit 1
  fi

  if [ "$DEBUG" == "true" ] 
  then
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
  else
    wipefs --all --backup $USB_KEY | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Erasing old partition scheme from $USB_KEY ..."
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Wipe done. Backup file of old partition scheme should be here: $(ls ~/wipefs-*.bak)"
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

    while IFS= read -r command; do
      $command | \
        show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Executing $command ..."

      PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
    done <<< $( cat << EOF
sgdisk --zap-all $USB_KEY
sgdisk --mbrtogpt $USB_KEY
sgdisk --new=0:0:+512M --typecode=0:EF00 $USB_KEY
mkfs.fat -F32 $EFI_PARTITION
sgdisk --new=0:0:+64M --typecode=0:8300 $USB_KEY
sgdisk --new=0:0:0 --typecode=0:8300 $USB_KEY
EOF
)
  fi
}

search_efi_partition() {
  DIALOG_SUBSTEP_TITLE="Search EFI partition"

  ls /sys/firmware/efi/efivars
  if [[ "$?" == "0" ]]
  then
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Looks like you booted in EFI mode. Let's search for an EFI partition!"
    EFI_PARTITION=$(fdisk --list -o device,type $USB_KEY | awk '/EFI/ { print $1 }')
    if [ "$EFI_PARTITION" != "" ]
    then
      show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Found an existing EFI partition at $EFI_PARTITION . Will use that!"
    else
      PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
      partition_usb
    fi
  else
    show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Did not found efi vars. Let's assume you booted in legacy bios mode ..."
  fi
}

search_boot_partition() {
  DIALOG_SUBSTEP_TITLE="Search boot partition"

  # Search for linux filesystem partitions with more than 100MB
  boot_partition=$(fdisk --list -o device,type,sectors $USB_KEY | awk '/Linux filesystem/ { if ($4 > 4096000) { print $1 } }')
  if [ "$boot_partition" != "" ]
  then
    show_yesno_menu "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Found a potential (encrypted) boot partition at $boot_partition . Should I use that? Otherwise I will wipe the usb stick and create new partitions on it."
    if [[ "$?" == "0" ]]
    then
      USE_EXISTING_BOOT_PARITION="true"
      BOOT_PARTITION="$boot_partition"
    else
      PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
      partition_usb
    fi
  fi
}

search_or_create_usb_partitions() {
  DIALOG_SUBSTEP_TITLE="Searching existing boot and EFI partitions"
  show_info_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "We will now search for existing partitions on the usb device."

  search_efi_partition
  PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
  search_boot_partition
}



##### -----> MAIN FUNCTION

search_or_create_usb_partitions
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
wipe_main_disk

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
