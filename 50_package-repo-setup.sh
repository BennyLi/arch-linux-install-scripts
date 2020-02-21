#! /usr/bin/env sh

PROGRESS_PERCENTAGE=50
DIALOG_STEP_TITLE="Package repositories" 

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Next we will configure the pacman repositories mirros and install some base packages ..."

mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

curl --silent "https://www.archlinux.org/mirrorlist/?country=${PACKAGE_MIRROR_COUNTRY}&protocol=${PACKAGE_MIRROR_PROTOCOL}&use_mirror_status=${PACKAGE_MIRROR_STATUS}" \
	| sed --expression 's/^#Server/Server/' --expression '/^#/d' \
	| tee --append /etc/pacman.d/mirrorlist \
    | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Downloading and amending mirrorlist ..."

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
