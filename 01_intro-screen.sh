#! /usr/bin/env sh

dialog --title "$DIALOG_TITLE" \
       --msgbox "Welcome. These scripts will guide you through the setup of a fully encrypted Arch Linux installation. You can configure some variable in the file $(readlink -f ./00_setup-variable.sh)" \
       $DIALOG_HEIGHT $DIALOG_WIDTH

clear

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
