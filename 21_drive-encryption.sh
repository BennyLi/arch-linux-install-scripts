#! /usr/bin/env sh

# We want to use encryption, so we have to load the kernel module for this
modprobe dm-crypt

echo "Next step is the encryption."
#echo "A benchmark will be run and you can choose the encryption type."
#read -p "Hit any key to continue..."
#cryptsetup benchmark
#read -p "Enter the encryption you want to use: " $encryptiontype


cryptsetup \
	--cypher $ENCRYPTION_TYPE \
	--verify-passphrase \
	--key-size $ENCRYPTION_KEYSIZE \
	luksFormat $ENCRYPTION_PARTITION


# Open the encrypted partition for following setup
cryptsetup luksOpen $ENCRYPTION_PARTITION lvm

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
