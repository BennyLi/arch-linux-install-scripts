#! /usr/bin/env sh

pacstrap /mnt/ \
	base base-devel \
	wpa_supplicant dialog \
	intel-ucode \
	git ansible \
	zsh
