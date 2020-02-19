#! /usr/bin/env sh

pacstrap /mnt/ \
	base base-devel \
	wpa_supplicant dialog \
	intel-ucode \
	git ansible \
	zsh

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
