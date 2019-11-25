#!/bin/bash

vgremove TempVG -y
pvremove /dev/sdb -y

touch /home/file{1..20}
ls /home
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{11..20}
ls /home
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
ls /home