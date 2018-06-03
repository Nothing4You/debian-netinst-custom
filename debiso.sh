#!/usr/bin/env bash

ver="$1"
if [ -z "$ver" ]
then
  ver="9.4.0"
fi

oldiso="debian-$ver-amd64-netinst.iso"
newiso="debian-$ver-amd64-netinst-custom.iso"

rm -rf cd "$newiso"

[ -f "$oldiso" ] || curl -LOJ "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/$oldiso"

mkdir cd
bsdtar -C cd/ -xf "$oldiso"
chmod -R +w cd

sed -re 's/(auto=true)/\1 net.ifnames=0/' -i cd/isolinux/adtxt.cfg
sed -re 's/(auto=true)/\1 net.ifnames=0/' -i cd/isolinux/adgtk.cfg

chmod -R -w cd

dd if="$oldiso" bs=1 count=432 of=isohdpfx.bin

xorriso -as mkisofs -o "$newiso" \
	-isohybrid-mbr isohdpfx.bin \
	-c isolinux/boot.cat -b isolinux/isolinux.bin \
	-no-emul-boot -boot-load-size 4 -boot-info-table ./cd

chmod -R +w cd
rm -rf cd isohdpfx.bin &> /dev/null || true
