#! /usr/bin/env zsh

# Get this script via https://git.io/JvEbY
# Execute curl -L https://git.io/JvEbY > init.sh && chmod +x init.sh && ./init.sh

if [[ ! -d $(pwd)/.git ]]
then
  which git > /dev/null
  if [[ "$?" != "0" ]]
  then
    pacman -Sy --noconfirm git
  fi
  git clone https://github.com/BennyLi/arch-linux-install-scripts.git
  cd arch-linux-install-scripts
  ./base-os-setup.sh
  exit 0
fi

# vim: set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
