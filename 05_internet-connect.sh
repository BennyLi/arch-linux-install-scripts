#! /usr/bin/env sh

for i in 5; do echo $i; sleep $DIALOG_PROGRESS_INFO_TIMEOUT; done | \
	dialog --title "$DIALOG_TITLE" \
	       --gauge "We will now check for internet connectivity ..." \
	       $DIALOG_HEIGHT $DIALOG_WIDTH

# Check connectivity
ping -c 5 -t 10 8.8.8.8 | \
	dialog --title "$DIALOG_TITLE" \
	       --progressbox "Checking internet connection ..." \
	       $DIALOG_HEIGHT $DIALOG_WIDTH


if [[ "$?" != "0" ]]; then 
  wifi=$(dialog --title "$DIALOG_TITLE" \
	        --stdout \
		--nocancel \
		--menu "Do you want to connect via wifi or ethernet?" \
		$DIALOG_HEIGHT $DIALOG_WIDTH 2 \
	       	0 ethernet \
		1 wifi)

  if [[ "$wifi" == "1" ]]; then
    wifi-menu
  else
    interfaces=$(ip -o link | awk '{ gsub(":","",$1); gsub(":","",$2); print $2 " " $1 }')
    interface=$(dialog --stdout --menu "Select network interface" 0 0 0 $interfaces)
    dhcpcd $interface
  fi
  
  ping -c 5 -t 10 8.8.8.8 | \
  	dialog --title "$DIALOG_TITLE" \
  	       --progressbox "Checking internet connection again ..." \
  	       $DIALOG_HEIGHT $DIALOG_WIDTH
  [[ "$?" == "0" ]] || \
  ( 
    dialog --title "$DIALOG_TITLE" \
	   --msgbox "Could not connect to the internet. Please make sure you can connect to the internet and try to run the install scripts again." \
  	   $DIALOG_HEIGHT $DIALOG_WIDTH
    exit 1
  )
fi


timedatectl set-ntp true

for i in 9; do echo $i; sleep $DIALOG_PROGRESS_INFO_TIMEOUT; done | \
  dialog --title "$DIALOG_TITLE" \
         --gauge "So we have an internet connection and the system time will be synced by ntp now. Let's move on!" \
         $DIALOG_HEIGHT $DIALOG_WIDTH

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
