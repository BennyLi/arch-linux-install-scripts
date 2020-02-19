#! /usr/bin/env sh

mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

curl --silent "https://www.archlinux.org/mirrorlist/?country=${PACKAGE_MIRROR_COUNTRY}&protocol=${PACKAGE_MIRROR_PROTOCOL}&use_mirror_status=${PACKAGE_MIRROR_STATUS}" \
	| sed --expression 's/^#Server/Server/' --expression '/^#/d' \
	| tee --append /etc/pacman.d/mirrorlist

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
