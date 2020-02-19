#! /usr/bin/env sh

arch-chroot /mnt useradd --create-home --user-group --shell /usr/bin/zsh --groups wheel,uucp,video,audio,storage,optical,games,input "$user"
arch-chroot /mnt chsh -s /usr/bin/zsh

echo "$user:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt

# TODO Move this to the ansible stuff
cat <<EOF > /mnt/etc/sudoers.d/01_benny
$user   ALL=(ALL) ALL
$user   NOPASSWD: /usr/bin/halt,/usr/bin/poweroff,/usr/bin/reboot
EOF

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
