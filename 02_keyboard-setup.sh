#! /usr/bin/env sh

dialog --title "$DIALOG_TITLE" \
       --msgbox "First of all we will setup your keyboard layout to the configured value, which is $KEYMAP" \
       $DIALOG_HEIGHT $DIALOG_WIDTH


# Load the key for your country
loadkeys $KEYMAP


clear
