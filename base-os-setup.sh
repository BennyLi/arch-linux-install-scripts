#! /usr/bin/env sh

# Sources of this process:
# * https://legacy.thomas-leister.de/arch-linux-luks-verschluesselt-auf-uefi-system-installieren-2/
# * https://disconnected.systems/blog/archlinux-installer/#the-complete-installer-script


source ./00_setup-variables.sh

source ./01_intro-screen.sh

source ./02_keyboard-setup.sh
source ./05_internet-connect.sh

source ./10_user-input.sh

source ./20_drive-preperation.sh
source ./30_drive-encryption.sh
source ./40_drive-partitioning.sh
# TODO
#source ./25_usb-pendrive-backup.sh
source ./49_drive-mount.sh

source ./50_package-repo-setup.sh
source ./51_package-base.sh

source ./60_base-system-config.sh
source ./61_user-setup.sh

source ./70_boot-configuration.sh

source ./80_advanced-user-installation.sh

source ./99_setup-finalize.sh

# vim: set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
