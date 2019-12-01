#!/bin/bash

sed -i "/s.path/s/\/.*[^']/\/move_xfs.sh/" Vagrantfile
sed -i "/s.args/s/\[.*\]/\['\/dev\/sdb', 'TempVG', 'TempLV', 'VolGroup00', 'LogVol00'\]/" Vagrantfile
vagrant up
sed -i "/s.args/s/\[.*\]/\['', 'VolGroup00', 'LogVol00', 'TempVG', 'TempLV'\]/" Vagrantfile
vagrant reload --provision
sed -i "/s.path/s/move_xfs.sh/remove_temp_vg.sh/" Vagrantfile
sed -i "/s.args/s/\[.*\]/\[\]/" Vagrantfile
vagrant reload --provision