#! /usr/bin/env sh

header_file_name=$(basename $LUKS_ROOT_HEADER_FILE)
mv $LUKS_ROOT_HEADER_FILE /mnt/boot
chmod 400 /mnt/boot/$header_file_name

key_file_name=$(basename $LUKS_BOOT_KEY_FILE)
mv $LUKS_BOOT_KEY_FILE /mnt/boot
chmod 400 /mnt/boot/$key_file_name

genfstab -p /mnt > /mnt/etc/fstab



# Custom encrypt hook
boot_device_id=$(ls -lth /dev/disk/by-id | grep -iP "$(basename $BOOT_PARTITION)" | awk '{print $9}')
root_device_id=$(ls -lth /dev/disk/by-id | grep -iP "$(basename $ENCRYPTION_PARTITION)" | awk '{print $9}')
cat << EOF > /etc/initcpio/hooks/detachedheader
#!/usr/bin/ash

run_hook() {
    modprobe -a -q dm-crypt >/dev/null 2>&1
    modprobe loop
    [ "${quiet}" = "y" ] && CSQUIET=">/dev/null"

    while [ ! -L '/dev/disk/by-id/$boot_device_id' ]; do
     echo 'Waiting for USB'
     sleep 1
    done

    cryptsetup open /dev/disk/by-id/$boot_device_id cryptboot
    mkdir -p /mnt
    mount /dev/mapper/cryptboot /mnt
    cryptsetup --header /mnt/$header_file_name --key-file=/mnt/$key_file_name --keyfile-size=$ENCRYPTION_KEYSIZE open /dev/disk/by-id/$root_device_id $LUKS_DEVICE_NAME
    umount /mnt
}
EOF

cp /mnt/usr/lib/initcpio/install/encrypt /mnt/etc/initcpio/install/encrypt





echo "Configuring bootmenu..."
sed --in-place 's/^HOOKS=.*/HOOKS="base udev keyboard autodetect modconf block keymap detachedheader lvm2 filesystems fsck"/g' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio --preset linux
arch-chroot /mnt bootctl install

cat <<EOF > /mnt/boot/loader/loader.conf
default arch
timeout 0
editor  no
console-mode max
EOF

lang_code_prefix="$(echo $LANG | sed --regexp-extended --quite 's/^(.*)_.*/\1/p')"
cat <<EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /intel-ucode.img
initrd   /initramfs-linux.img
options  cryptdevice=${root_device_id}:$LUKS_VOLUME_GROUP_NAME root=/dev/mapper/${LUKS_VOLUME_GROUP_NAME}-root resume=/dev/mapper/${LUKS_VOLUME_GROUP_NAME}-swap lang=${lang_code_prefix} locale=${LANG} pcie_aspm=off
EOF

# Auto update boot stuff
# Ensure directory exists first
mkdir --parent /mnt/etc/pacman.d/hooks
cat <<EOF > /mnt/etc/pacman.d/hooks/systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF



##### -----> GRUB SETUP
arch-chroot /mnt \
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Enable booting from LUKS encrypted devices
sed --in-place \
    --expression="s/^#GRUB_ENABLE_CRYPTODISK/GRUB_ENABLE_CRYPTODISK/g" \
    /etc/default/grub

arch-chroot /mnt \
  grub-mkconfig -o /boot/grub/grub.cfg

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
