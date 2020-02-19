#! /usr/bin/env sh

# Check connectivity
ping -c 1 8.8.8.8 >> /dev/null
if [[ "$?" == "0" ]]; then 
  echo "Already connected to the internet."

else
  # Lets connect to the internet
  wifi=$(dialog --stdout --menu "Do you want to connect via wifi or ethernet?" 0 0 0 0 ethernet 1 wifi) || exit 1
  if [ "$wifi" == "1" ]; then
    wifi-menu
  else
    interfaces=$(ip -o link | awk '{ gsub(":","",$1); gsub(":","",$2); print $2 " " $1 }')
    interface=$(dialog --stdout --menu "Select network interface" 0 0 0 $interfaces)
    dhcpcd $interface
  fi
  
  # Check connectivity
  ping -c 1 8.8.8.8 >> /dev/null
  [[ "$?" == "0" ]] || ( echo "No network connection! Please try again..."; exit 1; )
fi


# Setup clock
timedatectl set-ntp true
