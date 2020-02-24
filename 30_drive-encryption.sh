#! /usr/bin/env sh

DIALOG_STEP_TITLE="Drive encryption"
PROGRESS_PERCENTAGE=30

ENCRYPTION_PASS_FILE="/tmp/enc.pass"

# We want to use encryption, so we have to load the kernel module for this
modprobe dm-crypt


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
  dd if=/dev/urandom of=$LUKS_ROOT_KEYFILE_FILE bs=$ENCRYPTION_KEYSIZE count=1

  cryptsetup \
    --batch-mode \
    --verbose \
    --cipher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    --header $LUKS_ROOT_HEADER_FILE \
    --type luks2 \
    luksFormat $ENCRYPTION_PARTITION $LUKS_ROOT_KEYFILE_FILE | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the root parition ..."
}

open_root() {
  DIALOG_SUBSTEP_TITLE="Open root partition"

  cryptsetup luksOpen $ENCRYPTION_PARTITION \
    --header $LUKS_ROOT_HEADER_FILE \
    --key-file $LUKS_ROOT_KEYFILE_FILE \
    $LUKS_DEVICE_NAME | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted root device ..."
}


if [ "$DEBUG" == "true" ] 
then
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
else
  # TODO Check for existing boot and if boot is already encrypted 
  echo "$ENCYPTION_PASSPHRASE" > $ENCRYPTION_PASS_FILE
  encrypt_boot
  PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

  encrypt_root
  PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

  open_boot
  PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))
  open_root
fi

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
