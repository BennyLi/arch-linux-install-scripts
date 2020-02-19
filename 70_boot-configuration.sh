#! /usr/bin/env sh

genfstab -p /mnt > /mnt/etc/fstab


echo "Configuring bootmenu..."
sed --in-place 's/^HOOKS=.*/HOOKS="base udev keyboard autodetect modconf block keymap encrypt lvm2 filesystems fsck"/g' /mnt/etc/mkinitcpio.conf
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
options  cryptdevice=${ENCRYPTION_PARTITION}:main root=/dev/mapper/main-root resume=/dev/mapper/main-swap lang=${lang_code_prefix} locale=${LANG} pcie_aspm=off
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

