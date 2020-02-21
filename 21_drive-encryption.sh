#! /usr/bin/env sh

DIALOG_STEP_TITLE="Drive encryption"
PROGRESS_PERCENTAGE=21

# We want to use encryption, so we have to load the kernel module for this
modprobe dm-crypt


encrypt_boot() {
  DIALOG_SUBSTEP_TITLE="Encrypt usb boot partition"

  cryptsetup \
    --cypher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    luksFormat $BOOT_PARTITION ~/encryption.pass | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the usb boot partition ..."
}

open_boot() {
  DIALOG_SUBSTEP_TITLE="Open usb boot partition"

  cryptsetup luksOpen $BOOT_PARTITION ~/encryption.pass | \
    show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted usb boot partition ..."
}

encrypt_root() {
  DIALOG_SUBSTEP_TITLE="Encrypt root partition"

  dd if=/dev/urandom of=luks_root_header bs=4M count=1
  dd if=/dev/urandom of=luks_root_keyfile bs=$ENCRYPTION_KEYSIZE count=1

  cryptsetup \
    --cypher $ENCRYPTION_TYPE \
    --key-size $ENCRYPTION_KEYSIZE \
    --header luks_root_header \
    --type luks2 \
    luksFormat $ENCRYPTION_PARTITION luks_root_keyfile | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Encrypting the root parition ..."
}

open_root() {
  DIALOG_SUBSTEP_TITLE="Open root partition"

  cryptsetup luksOpen $ENCRYPTION_PARTITION \
    --header luks_root_header \
    --key-file luks_root_keyfile \
    $LUKS_DEVICE_NAME | \
      show_progress_box "$DIALOG_STEP_TITLE - $DIALOG_SUBSTEP_TITLE" $PROGRESS_PERCENTAGE "Opening the encrypted root device ..."
}


echo "$ENCYPTION_PASSPHRASE" > ~/encryption.pass
encrypt_boot
encrypt_root

open_boot
open_root
rm ~/.encrpytion.pass

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
