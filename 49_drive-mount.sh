#! /usr/bin/env sh

DIALOG_STEP_TITLE="LUKS device mounting"
PROGRESS_PERCENTAGE=29

while IFS= read -r command; do
  $command | \
    show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Executing $command ..."

  PROGRESS_PERCENTAGE=$(( $PROGRESS_PERCENTAGE + 1 ))
done <<< $( cat << EOF
mount /dev/mapper/${LUKS_VOLUME_GROUP_NAME}-root /mnt
mkdir /mnt/efi
mount $EFI_PARTITION /mnt/efi
mkdir /mnt/boot
mount /dev/mapper/$LUKS_BOOT_DEVICE_NAME /mnt/boot
swapon /dev/mapper/${LUKS_VOLUME_GROUP_NAME}-swap
EOF
)

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
