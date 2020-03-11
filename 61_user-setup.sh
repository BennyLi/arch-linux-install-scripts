#! /usr/bin/env sh

PROGRESS_PERCENTAGE=61
DIALOG_STEP_TITLE="User setup"

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "In this step the user will be added using your provided username and password."

arch-chroot /mnt groupadd "$USERGROUP" \
  | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Creating user group $USERGROUP ..."
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

arch-chroot /mnt useradd \
                  --create-home \
                  --shell /usr/bin/zsh \
                  -g "$USERGROUP" \
                  --groups wheel,uucp,video,audio,storage,optical,games,input \
                  "$USERNAME" \
  | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Creating user $USERNAME ..."
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd \
  | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Setting user password ..."
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

echo "root:$USER_PASSWORD" | arch-chroot /mnt chpasswd \
  | show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Setting root password ..."
PROGRESS_PERCENTAGE=$(( PROGRESS_PERCENTAGE + 1 ))

# TODO Move this to the ansible stuff
cat <<EOF > /mnt/etc/sudoers.d/01_benny
$USERNAME   ALL=(ALL) ALL
$USERNAME   NOPASSWD: /usr/bin/halt,/usr/bin/poweroff,/usr/bin/reboot
EOF

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
