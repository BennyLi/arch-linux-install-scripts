#! /usr/bin/env sh

# Variable that hold fixed values
DEBUG=true # if true no data will be changed

KEYMAP="de-latin1-nodeadkeys"
LANG="de_DE.UTF-8"
LOCALTIME_ZONE="Europe/Berlin"

PACKAGE_MIRROR_COUNTRY="DE"
PACKAGE_MIRROR_STATUS="on"
PACKAGE_MIRROR_PROTOCOL="https"

ENCRYPTION_TYPE="aes-xts-plain"
ENCRYPTION_KEYSIZE="512"

# Variable that will be set in the setup process
HOSTNAME=""
USERNAME=""
USER_PASSWORD=""

INSTALL_DEVICE=""
ENCRYPTION_PARTITION=""
USB_KEY=""
EFI_PARTITION=""
BOOT_PARTITION=""



DIALOG_BACKTITLE="Arch Linux Setup"
DIALOG_HEIGHT="15"
DIALOG_WIDTH="80"



# Enable modeline for vim (just for the live environment)
echo "set modeline" >> /etc/vimrc



#####----->  HELPER FUNCTIONS

show_info_box() {
  local DIALOG_STEP_TITLE="$1"
  local PROGRESS_PERCENTAGE="$2"
  local INFO_TEXT="$3"

  dialog --backtitle "$DIALOG_BACKTITLE" \
         --title "$DIALOG_STEP_TITLE (Total progress:  ${PROGRESS_PERCENTAGE}%)" \
         --ascii-lines \
         --infobox "\n$INFO_TEXT\n\n\n                       Press any key to continue..." \
         $DIALOG_HEIGHT $DIALOG_WIDTH
  read -n 1
}

show_progress_box() {
  local DIALOG_STEP_TITLE="$1"
  local PROGRESS_PERCENTAGE="$2"
  local INFO_TEXT="$3"

  dialog --backtitle "$DIALOG_BACKTITLE" \
         --title "$DIALOG_STEP_TITLE (Total progress:  ${PROGRESS_PERCENTAGE}%)" \
         --ascii-lines \
         --progressbox "\n$INFO_TEXT" \
         $DIALOG_HEIGHT $DIALOG_WIDTH
}

show_input_box() {
  local DIALOG_STEP_TITLE="$1"
  local PROGRESS_PERCENTAGE="$2"
  local INFO_TEXT="$3"

  dialog --backtitle "$DIALOG_BACKTITLE" \
         --title "$DIALOG_STEP_TITLE (Total progress:  ${PROGRESS_PERCENTAGE}%)" \
         --ascii-lines \
         --stdout \
         --no-cancel \
         --inputbox "\n$INFO_TEXT" \
         $DIALOG_HEIGHT $DIALOG_WIDTH
}

show_password_box() {
  local DIALOG_STEP_TITLE="$1"
  local PROGRESS_PERCENTAGE="$2"
  local INFO_TEXT="$3"

  dialog --backtitle "$DIALOG_BACKTITLE" \
         --title "$DIALOG_STEP_TITLE (Total progress:  ${PROGRESS_PERCENTAGE}%)" \
         --ascii-lines \
         --stdout \
         --no-cancel \
         --insecure \
         --passwordbox "\n$INFO_TEXT" \
         $DIALOG_HEIGHT $DIALOG_WIDTH
}

show_selection_menu() {
  local DIALOG_STEP_TITLE="$1"
  shift
  local PROGRESS_PERCENTAGE="$1"
  shift
  local INFO_TEXT="$1"
  shift
  local OPTIONS_LIST="$@"

  dialog --backtitle "$DIALOG_BACKTITLE" \
         --title "$DIALOG_STEP_TITLE (Total progress:  ${PROGRESS_PERCENTAGE}%)" \
         --ascii-lines \
         --stdout \
         --menu "\n$INFO_TEXT" \
         $DIALOG_HEIGHT $DIALOG_WIDTH 0 \
         ${OPTIONS_LIST}
}

# Exit with a clear message on failures
#set -uo pipefail
#trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

#####  Set up logging  ##### {{{1
#exec 1> >(tee "stdout.log")
#exec 2> >(tee "stderr.log")

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
