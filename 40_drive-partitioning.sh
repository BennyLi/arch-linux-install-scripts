#! /usr/bin/env sh

DIALOG_STEP_TITLE="LUKS device partitioning"
PROGRESS_PERCENTAGE=40

if [ "$DEBUG" == "true" ] 
then
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "DEBUG is on, nothing will be done here yet ..."
else
  ram_size=$(free --mebi | awk '/Mem:/ {print $2}')

  while IFS= read -r command; do
    $command | \
      show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Executing $command ..."

    PROGRESS_PERCENTAGE=$(( $PROGRESS_PERCENTAGE + 1 ))
  done <<< $( cat << EOF
pvcreate -ff --yes /dev/mapper/$LUKS_BOOT_DEVICE_NAME
pvcreate -ff --yes /dev/mapper/$LUKS_DEVICE_NAME
vgcreate $LUKS_BOOT_VOLUME_GROUP_NAME /dev/mapper/$LUKS_BOOT_DEVICE_NAME
vgcreate $LUKS_VOLUME_GROUP_NAME /dev/mapper/$LUKS_DEVICE_NAME
lvcreate --extents 100%FREE --name boot $LUKS_BOOT_VOLUME_GROUP_NAME
lvcreate --size $ram_size --name swap $LUKS_VOLUME_GROUP_NAME
lvcreate --extents 100%FREE --name root $LUKS_VOLUME_GROUP_NAME
mkfs.ext2 /dev/mapper/${LUKS_BOOT_VOLUME_GROUP_NAME}-boot
mkfs.ext4 /dev/mapper/${LUKS_VOLUME_GROUP_NAME}-root
mkswap /dev/mapper/${LUKS_VOLUME_GROUP_NAME}-swap
EOF
)
fi

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
