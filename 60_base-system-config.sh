#! /usr/bin/env sh

echo "Setting hostname ..."
echo $HOSTNAME > /mnt/etc/hostname

echo "Generating locales ..."
echo "LANG=${LANG}" > /mnt/etc/locale.conf
lang_code="$(echo $LANG | sed --extended-regexp --quiet 's/^(.*)\..*/\1/p')"
sed --in-place \
    --expression="s/^#en_US/en_US/g" \
    --expression="s/^#${lang_code}/${lang_code}/g" \
    /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo "Setting console keyboard layout to ${KEYMAP} ..."
echo "KEYMAP=${KEYMAP}" > /mnt/etc/vconsole.conf

echo "Setting localtime to ${LOCALTIME_ZONE} ..."
rm --force /mnt/etc/localtime
arch-chroot /mnt/ ln --symbolic /usr/share/zoneinfo/${LOCALTIME_ZONE} /etc/localtime

# vim: set tabstop=2 softtabstop=0 expandtab shiftwidth=2 number:
