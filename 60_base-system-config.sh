#! /usr/bin/env sh

PROGRESS_PERCENTAGE=60
DIALOG_STEP_TITLE="Basic configuration" 

show_info_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Now we will configure the system and the things like\n\n * The hostname\n * Locales\n * Keymap \n * Localtime"

echo $HOSTNAME > /mnt/etc/hostname

echo "LANG=${LANG}" > /mnt/etc/locale.conf
lang_code="$(echo $LANG | sed --extended-regexp --quiet 's/^(.*)\..*/\1/p')"
sed --in-place \
    --expression="s/^#en_US/en_US/g" \
    --expression="s/^#${lang_code}/${lang_code}/g" \
    /mnt/etc/locale.gen
arch-chroot /mnt locale-gen | \
  show_progress_box "$DIALOG_STEP_TITLE" $PROGRESS_PERCENTAGE "Generating locales ..."

echo "Setting console keyboard layout to ${KEYMAP} ..."
echo "KEYMAP=${KEYMAP}" > /mnt/etc/vconsole.conf

echo "Setting localtime to ${LOCALTIME_ZONE} ..."
rm --force /mnt/etc/localtime
arch-chroot /mnt/ ln --symbolic /usr/share/zoneinfo/${LOCALTIME_ZONE} /etc/localtime

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
