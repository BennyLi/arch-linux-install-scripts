#! /usr/bin/env sh

PROGRESS_BASE=10
DIALOG_STEP_TITLE="User input" 

show_intro_screen() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Next I will ask you for some variable data. Please provide each one as it will be set in the installation process for you."
}


get_hostname() {
  HOSTNAME=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Enter your hostname / machine name / name of your computer:")
}


get_username() {
  USERNAME=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Enter admin username:")
}

show_user_password_dialog() {
  USER_PASSWORD=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Enter admin password:")
}

confirm_user_password() {
  password_check="0"
  password_check=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Enter admin password again:")

  if [[ "$USER_PASSWORD" != "$password_check" ]]
  then
    show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "ERROR: The provided passwords did not match! Please try again."
    USER_PASSWORD=""
  fi
}

get_user_password() {
  while [[ "$USER_PASSWORD" == "" ]]; do show_user_password_dialog; done
  confirm_user_password
}

get_install_disk() {
  devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
  INSTALL_DEVICE=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_BASE \
                                       "Please select the medium where Arch Linux should be installed on.\n\nWARNING: THIS DISK WILL BE WIPED COMPLETLY!\nTHIS CANNOT BE UNDONE!\nALL YOUR DATA ON THAT DEVICE WILL BE LOST!\n\nCANCEL IF YOU WISH TO MAKE A BACKUP FIRST!" \
                                       ${devicelist} ) || exit 1

  ENCRYPTION_PARTITION="$(ls ${INSTALL_DEVICE}* | grep -E "^${INSTALL_DEVICE}p?1$")"
}

show_install_disk_info() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Nice! You selected $INSTALL_DEVICE as the device where Arch Linux will be installed.\n\nA partition at $ENCRYPTION_PARTITION will be created and then encrypted."
}

get_usb_boot_device() {
  devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
  USB_KEY=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_BASE \
                                "Select the usb key device to store the LUKS header and boot partition on.\n\nThe setup will try to detect an existing boot partition and will use that. But more on this later." \
                                ${devicelist} ) || exit 1

  EFI_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?1$")"
  EFI_PARTITION="${EFI_PARTITION:=${USB_KEY}1}"
  BOOT_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?2$")"
  BOOT_PARTITION="${BOOT_PARTITION:=${USB_KEY}2}"
}

show_usb_disk_info() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_BASE "Excellent! You selected $USB_KEY as the device where the LUKS header and the boot partition will be stored on.\n\nTwo partitions are created later, if they do not already exists.\n  * The EFI system partition at $EFI_PARTITION\n  * The boot partition at $BOOT_PARTITION"
}


##### ----- MAIN FUNCTION

show_intro_screen

while [[ "$HOSTNAME" == "" ]]; do get_hostname; done
PROGRESS_BASE=$((PROGRESS_BASE + 1))
while [[ "$USERNAME" == "" ]]; do get_username; done
PROGRESS_BASE=$((PROGRESS_BASE + 1))
while [[ "$USER_PASSWORD" == "" ]]; do get_user_password; done
PROGRESS_BASE=$((PROGRESS_BASE + 1))

get_install_disk
PROGRESS_BASE=$((PROGRESS_BASE + 1))
show_install_disk_info

get_usb_boot_device
PROGRESS_BASE=$((PROGRESS_BASE + 1))
show_usb_disk_info


# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
