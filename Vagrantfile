# frozen_string_literal: true

# -*- mode: ruby -*-
# vim: set ft=ruby :

VMS_PATH = `VBoxManage list systemproperties |
  grep "Default machine folder:" | awk '{print $4}' | tr -d '\n'`
NAME_MACHINE = 'lvm-012020'

ENV['LC_ALL'] = 'en_US.UTF-8'

MACHINES = {
  lvm: {
    box_name: 'centos/7',
    box_version: '1804.02',
    ip_addr: '192.168.11.101',
    disks: {
      sata1: {
        dfile: "sata1.vdi",
        size: 10_240,
        port: 1
      },
      sata2: {
        dfile: "sata2.vdi",
        size: 2048, # Megabytes
        port: 2
      },
      sata3: {
        dfile: "sata3.vdi",
        size: 1024, # Megabytes
        port: 3
      },
      sata4: {
        dfile: "sata4.vdi",
        size: 1024,
        port: 4
      }
    }
  }
}.freeze

Vagrant.configure('2') do |config|
  config.vm.box_version = '1804.02'
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s

      # box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

      box.vm.network 'private_network', ip: boxconfig[:ip_addr]

      box.vm.provider :virtualbox do |vb|
        vb.name = NAME_MACHINE
        vb.customize ['modifyvm', :id, '--memory', '256', '--audio', 'none']
        needsController = false
        boxconfig[:disks].each do |_dname, dconf|
          dfile_disk = "#{VMS_PATH}/#{NAME_MACHINE}/#{dconf[:dfile]}"
          unless File.exist?(dfile_disk)
            vb.customize ['createhd', '--filename', dfile_disk, '--variant', 'Fixed', '--size', dconf[:size]]
            needsController = true
          end
        end
        if needsController == true
          vb.customize ['storagectl', :id, '--name', 'SATA', '--add', 'sata']
          boxconfig[:disks].each do |_dname, dconf|
            dfile_disk = "#{VMS_PATH}/#{NAME_MACHINE}/#{dconf[:dfile]}"
            vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dfile_disk]
          end
        end
      end

      box.vm.provision 'shell' do |s|
        s.path = 'scripts/remove_temp_vg.sh'
        s.args = []
      end
    end
  end
end
