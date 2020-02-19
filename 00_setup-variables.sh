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
USER_PASSWORD

INSTALL_DEVICE
ENCRYPTION_PARTITION
USB_KEY
EFI_PARTITION
BOOT_PARTITION




# Exit with a clear message on failures
#set -uo pipefail
#trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

#####  Set up logging  ##### {{{1
#exec 1> >(tee "stdout.log")
#exec 2> >(tee "stderr.log")
