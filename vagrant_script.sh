#!/bin/bash

vagrant up
sed -i "/s.path/s/init.sh/move_xfs.sh/" Vagrantfile
sed -i "/s.args/s/\[\]/\['\/dev\/sdb','TempVG','TempLV','VolGroup00','LogVol00'\]/" Vagrantfile
vagrant reload --provision
vagrant reload
