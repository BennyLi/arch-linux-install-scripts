#! /usr/bin/env sh

PROGRESS_PERCENTAGE=51
DIALOG_STEP_TITLE="Package installation"

pacstrap /mnt/ \
  base base-devel \
  linux linux-firmware \
  grub \
  wpa_supplicant dialog \
  intel-ucode \
  git ansible \
  zsh | \
    show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Executing pacstrap ..."

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
