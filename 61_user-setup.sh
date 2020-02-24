#! /usr/bin/env sh

PROGRESS_PERCENTAGE=61
DIALOG_STEP_TITLE="User setup" 

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "In this step the user will be added using your provided username and password."

arch-chroot /mnt useradd --create-home --user-group --shell /usr/bin/zsh --groups wheel,uucp,video,audio,storage,optical,games,input "$USERNAME"
arch-chroot /mnt chsh -s /usr/bin/zsh

echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd
echo "root:$USER_PASSWORD" | arch-chroot /mnt chpasswd

# TODO Move this to the ansible stuff
cat <<EOF > /mnt/etc/sudoers.d/01_benny
$USERNAME   ALL=(ALL) ALL
$USERNAME   NOPASSWD: /usr/bin/halt,/usr/bin/poweroff,/usr/bin/reboot
EOF

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
