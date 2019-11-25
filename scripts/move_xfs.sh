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

chroot /mnt /bin/bash <<EOT
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot
for i in \$(ls initramfs-*img); do
  dracut -v \$i \$(echo \$i | sed "s/initramfs-//g; s/.img//g") --force
done
sed -i "s/$4\/$5/$2\/$3/" /boot/grub2/grub.cfg
if [ "$1" = '' ]; then
  pvcreate /dev/sdc /dev/sdd
  vgcreate vg_var /dev/sdc /dev/sdd
  lvcreate -L 950M -m1 -n lv_var vg_var -y
  mkfs.ext4 /dev/vg_var/lv_var
  mount /dev/vg_var/lv_var /mnt
  cp -aR /var/* /mnt/
  rsync -avHPSAX /var/ /mnt/
  rm -rf /var/*
  umount /mnt
  mount /dev/vg_var/lv_var /var
  echo "\$(blkid | grep var: | awk '{print \$2}') /var ext4 defaults 0 0" >> /etc/fstab
fi
EOT