#! /usr/bin/env sh

echo "Creating LVM volume group..."
pvcreate /dev/mapper/lvm
vgcreate main /dev/mapper/lvm

ram_size=$(free --mebi | awk '/Mem:/ {print $2}')
echo "Creating LVM swap volume of size $ram_size ..."
lvcreate --size $ram_size --name swap main

echo "Creating LVM root volume, filling the rest of the free space ..."
lvcreate --extends 100%FREE --name root main



echo "Creating swap file system ..."
mkswap /dev/mapper/main-swap

echo "Creating ext4 file system on the root volume ..."
mkfs.ext4 /dev/mapper/main-root
