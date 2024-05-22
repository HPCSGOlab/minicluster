#!/bin/bash -xe

DLNAME=jetson_linux_r36.3.0_aarch64.tbz2
OD=`pwd`

# KERNEL
# this is  for jetpack 36.3. Will have to update this script in the future if we want to support future jetpacks; not sure
# how consistent the naming conventions are
wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/release/${DLNAME}
tar xvf ${DLNAME}
cd Linux_for_Tegra/source
./source_sync.sh

cp ${OD}/kernel/.config kernel/kernel-jammy-src/
cp ${OD}/kernel/Makefile kernel/

mkdir kernel_out
./nvbuild.sh -o kernel_out
#TODO check this actually replaces /boot/Image and /boot/initrd
sudo ./nvbuild.sh -i
cp /boot/Image ${OD}/root/srv/tftp/Image
cd $OD

#INITRD
cd initrd
sudo rm -rf root
mkdir -p root
cd root
sudo gzip -dc /boot/initrd | sudo cpio -idmv
cp ../init root/
find . | sudo cpio -o -H newc | sudo gzip -9 > ${OD}/root/srv/tftp/initrd
cd $OD

# this will do apt update
sudo unminimize

sudo apt install -y build-essential bc libdwarf libncurses-dev vim htop locate libssl-dev nfs-kernel-server tftpd-hpa  isc-dhcp-server ntp
sudo systemctl enable nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp
sudo updatedb

sudo mkdir /etc/exports.d

sudo systemctl restart nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp


# copy configs over
sudo cp -r root/* /

echo "Finished setup without errors. Reboot to reflect changes..."
