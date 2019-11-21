#!/bin/bash

#sed -i "/s.path/s/\/.*[^']/\/init.sh/" Vagrantfile
#vagrant up
#sed -i "/s.path/s/init.sh/move_xfs.sh/" Vagrantfile
sed -i "/s.path/s/\/.*[^']/\/move_xfs.sh/" Vagrantfile
sed -i "/s.args/s/\[.*\]/\['\/dev\/sdb', 'TempVG', 'TempLV', 'VolGroup00', 'LogVol00'\]/" Vagrantfile
#vagrant reload --provision
vagrant up
sed -i "/s.args/s/\[.*\]/\['', 'VolGroup00', 'LogVol00', 'TempVG', 'TempLV'\]/" Vagrantfile
vagrant reload --provision
sed -i "/s.path/s/move_xfs.sh/var_home.sh/" Vagrantfile
sed -i "/s.args/s/\[.*\]/\[\]/" Vagrantfile
vagrant reload --provision