#! /usr/bin/env sh

PROGRESS_PERCENTAGE=10
DIALOG_STEP_TITLE="User input" 

show_intro_screen() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Next I will ask you for some variable data. Please provide each one as it will be set in the installation process for you."
}

get_hostname() {
  HOSTNAME=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter your hostname / machine name / name of your computer:")
}

get_username() {
  USERNAME=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter admin username:")
}

get_usergroup() {
  USERGROUP=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter usergroup for $USERNAME:")
}

show_user_password_dialog() {
  USER_PASSWORD=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter password for $USERNAME:")
}

confirm_user_password() {
  password_check="0"
  password_check=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter that password again:")

  if [[ "$USER_PASSWORD" != "$password_check" ]]
  then
    show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "ERROR: The provided passwords did not match! Please try again."
    USER_PASSWORD=""
  fi
}

get_user_password() {
  while [[ "$USER_PASSWORD" == "" ]]; do show_user_password_dialog; done
  confirm_user_password
}

get_install_disk() {
  devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
  INSTALL_DEVICE=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE \
                                       "Please select the medium where Arch Linux should be installed on.\n\nWARNING: THIS DISK WILL BE WIPED COMPLETLY!\nTHIS CANNOT BE UNDONE!\nALL YOUR DATA ON THAT DEVICE WILL BE LOST!\n\nCANCEL IF YOU WISH TO MAKE A BACKUP FIRST!" \
                                       ${devicelist} ) || exit 1

  # Use the whole drive for encryption so nothing is visible at all (even no partitions)
  ENCRYPTION_PARTITION="$INSTALL_DEVICE"
  #ENCRYPTION_PARTITION="$(ls ${INSTALL_DEVICE}* | grep -E "^${INSTALL_DEVICE}p?1$")"
}

show_install_disk_info() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Nice! You selected $INSTALL_DEVICE as the device where Arch Linux will be installed.\n\nA partition at $ENCRYPTION_PARTITION will be created and then encrypted."
}

get_usb_boot_device() {
  devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
  USB_KEY=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE \
                                "Select the usb key device to store the LUKS header and boot partition on.\n\nThe setup will try to detect an existing boot partition and will use that. But more on this later." \
                                ${devicelist} ) || exit 1

  EFI_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?1$")"
  EFI_PARTITION="${EFI_PARTITION:=${USB_KEY}1}"
  KEY_STORAGE_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?2$")"
  KEY_STORAGE_PARTITION="${KEY_STORAGE_PARTITION:=${USB_KEY}2}"
  BOOT_PARTITION="$(ls ${USB_KEY}* | grep -E "^${USB_KEY}p?3$")"
  BOOT_PARTITION="${BOOT_PARTITION:=${USB_KEY}3}"
}

show_usb_disk_info() {
  show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Excellent! You selected $USB_KEY as the device where the LUKS header and the boot partition will be stored on.\n\nThree partitions are created later, if they do not already exists.\n  * The EFI system partition at $EFI_PARTITION\n  * The encrypted key storage partition at $KEY_STORAGE_PARTITION\n  * The encrypted boot partition at $BOOT_PARTITION"
}

show_encryption_password_dialog() {
  ENCRYPTION_PASSPHRASE=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter device encryption password (will be asked on boot):")
}

confirm_encryption_password() {
  password_check="0"
  password_check=$(show_password_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter device encryption password again:")

  if [[ "$ENCRYPTION_PASSPHRASE" != "$password_check" ]]
  then
    show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "ERROR: The provided passwords did not match! Please try again."
    ENCRYPTION_PASSPHRASE=""
  fi
}

get_encryption_password() {
  while [[ "$ENCRYPTION_PASSPHRASE" == "" ]]; do show_encryption_password_dialog; done
  confirm_encryption_password
}

get_ansible_repo_url() {
  ANSIBLE_GIT_REPO_URL=$(show_input_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Enter the URL OR local path to your ansible git repo:")
}


##### -----> MAIN FUNCTION

show_intro_screen

while [[ "$HOSTNAME" == "" ]]; do get_hostname; done
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
while [[ "$USERNAME" == "" ]]; do get_username; done
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
while [[ "$USERGROUP" == "" ]]; do get_usergroup; done
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
while [[ "$USER_PASSWORD" == "" ]]; do get_user_password; done
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))

get_install_disk
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
show_install_disk_info

get_usb_boot_device
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
show_usb_disk_info

while [[ "$ENCRYPTION_PASSPHRASE" == "" ]]; do get_encryption_password; done
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))

while [[ "$ANSIBLE_GIT_REPO_URL" == "" ]]; do get_ansible_repo_url; done

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
