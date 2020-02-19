#! /usr/bin/env sh

PROGRESS_PERCENTAGE=1

show_info_box "Keyboard Setup" $PROGRESS_PERCENTAGE "First of all we will setup your keyboard layout to the configured value, which is\n\n * $KEYMAP"


# Load the key for your country
loadkeys $KEYMAP


# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
