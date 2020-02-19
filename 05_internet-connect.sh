#! /usr/bin/env sh

PROGRESS_PERCENTAGE=5
DIALOG_STEP_TITLE="Internet connection setup"

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "We will now check for internet connectivity ..."

ping -c 5 -t 10 8.8.8.8 | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Checking internet connection ..."
PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))

if [[ "$?" != "0" ]]; then 
  wifi=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE \
                             "Do you want to connect via wifi or ethernet?" \
	                           0 ethernet \
		                         1 wifi)
  PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))

  if [[ "$wifi" == "1" ]]; then
    wifi-menu
  else
    interfaces=$(ip -o link | awk '{ gsub(":","",$1); gsub(":","",$2); print $2 " " $1 }')
    interface=$(show_selection_menu "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE \
                                    "Select network interface" \
                                    $interfaces)
    dhcpcd $interface
    PROGRESS_PERCENTAGE=$((PROGRESS_PERCENTAGE + 1))
  fi
  
  ping -c 5 -t 10 8.8.8.8 | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Checking internet connection again ..."
  
  [[ "$?" == "0" ]] || \
  ( 
    show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE \
                  "Could not connect to the internet. Please make sure you can connect to the internet and try to run the install scripts again."
    exit 1
  )
fi


timedatectl set-ntp true
PROGRESS_PERCENTAGE=9

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "So we have an internet connection and the system time will be synced by ntp now. Let's move on!"

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
