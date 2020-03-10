#! /usr/bin/env sh

DIALOG_STEP_TITLE="Drive encryption"
PROGRESS_PERCENTAGE=30

ENCRYPTION_PASS_FILE="/tmp/enc.pass"

# We want to use encryption, so we have to load the kernel module for this
modprobe dm-crypt


boot_exists() {
  efi_partition=$(fdisk --list -o device,type $USB_KEY | awk '/EFI/ { print $1 }')
  if [[ "$efi_partition" != "" ]]
  then
    # Search for linux filesystem partitions with more than 100MB
    boot_partition=$(fdisk --list -o device,type,sectors $USB_KEY | awk '/Linux filesystem/ { if ($4 > 4096000) { print $1 } }')
    if [[ "$boot_partition" != "" ]]
    then
      echo "Partition that could contain boot found!"
    else
      exit 1
    fi
  else
    exit 1
  fi
}

encrypt_key_storage() {
  DIALOG_SUBSTEP_TITLE="Encrypt usb key storage partition"

  cryptsetup \
    --batch-mode \
    --verbose \
    --cipher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    --type luks1 \
    luksFormat $KEY_STORAGE_PARTITION $ENCRYPTION_PASS_FILE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the usb key storage partition ..."
}

open_key_storage() {
  DIALOG_SUBSTEP_TITLE="Open usb key storage partition"

  cryptsetup luksOpen \
    --key-file $ENCRYPTION_PASS_FILE \
    $KEY_STORAGE_PARTITION \
    $LUKS_KEY_STORAGE_DEVICE_NAME | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted usb key storage partition ..."
}

encrypt_boot() {
  DIALOG_SUBSTEP_TITLE="Encrypt usb boot partition"

  cryptsetup \
    --batch-mode \
    --verbose \
    --cipher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    --type luks1 \
    luksFormat $BOOT_PARTITION $ENCRYPTION_PASS_FILE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the usb boot partition ..."
}

open_boot() {
  DIALOG_SUBSTEP_TITLE="Open usb boot partition"

  cryptsetup luksOpen \
    --key-file $ENCRYPTION_PASS_FILE \
    $BOOT_PARTITION \
    $LUKS_BOOT_DEVICE_NAME | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted usb boot partition ..."
}

encrypt_root() {
  DIALOG_SUBSTEP_TITLE="Encrypt root partition"

  dd if=/dev/urandom of=$LUKS_ROOT_HEADER_FILE bs=4M count=1
  dd if=/dev/urandom of=$LUKS_ROOT_KEY_FILE bs=$ENCRYPTION_KEYSIZE count=1
  chmod "u=r,g=,o=" $LUKS_ROOT_HEADER_FILE
  chmod "u=r,g=,o=" $LUKS_ROOT_KEY_FILE

  cryptsetup \
    --batch-mode \
    --verbose \
    --cipher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    --header $LUKS_ROOT_HEADER_FILE \
    --type luks2 \
    luksFormat $ENCRYPTION_PARTITION $LUKS_ROOT_KEY_FILE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the root parition ..."
}

open_root() {
  DIALOG_SUBSTEP_TITLE="Open root partition"

  cryptsetup luksOpen $ENCRYPTION_PARTITION \
    --header $LUKS_ROOT_HEADER_FILE \
    --key-file $LUKS_ROOT_KEY_FILE \
    $LUKS_DEVICE_NAME | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted root device ..."
}


if [ "$DEBUG" == "true" ]
then
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
else
  echo -n "$ENCRYPTION_PASSPHRASE" > $ENCRYPTION_PASS_FILE

  if [[ "$USE_EXISTING_BOOT_PARTITION" == "true" ]]
  then
    $(open_boot)
    if [[ "$?" != "0" ]]
    then
      show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Could not open encrypted boot partition! Check if you\n * $BOOT_PARTITION is correct\n * The given passphrase is correct\n\nWill abort now! Please try again ..."
      exit 1
    else
      show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Existing boot partition found and in use!"
    fi
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
  else
    encrypt_key_storage
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
    open_key_storage
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
    encrypt_boot
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
    open_boot
    PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
  fi

  encrypt_root
  PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
  open_root
fi

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
