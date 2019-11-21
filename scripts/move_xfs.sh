#!/bin/bash
# $1 - device
# $2 - name destination VG
# $3 - name destination LV
# $4 - name source VG
# $5 - name source LV

DEST_DEVICE=/dev/$2/$3
SOURCE_DEVICE=/dev/$4/$5

lsblk

if [ "$1" != '' ]; then
  mkdir -p ~root/.ssh
  cp ~vagrant/.ssh/auth* ~root/.ssh
  yum install -y xfsdump
  
  pvcreate $1
  vgcreate $2 $1
  lvcreate -n $3 -l +100%FREE /dev/$2
else
  lvremove $DEST_DEVICE -y
  lvcreate -n $3 -L 8G $2 -y
fi

mkfs.xfs $DEST_DEVICE
mount $DEST_DEVICE /mnt

xfsdump -J - $SOURCE_DEVICE | xfsrestore -J - /mnt

for i in /proc/ /sys/ /dev/ /run/ /boot/; do
  mount --bind $i /mnt/$i
done

cat <<EOF | chroot /mnt
grub2-mkconfig -o /boot/grub2/grub.cfg
sed -i "s/$4\/$5/$2\/$3/" /boot/grub2/grub.cfg
EOF
