#!/bin/bash -xe


echo "WARNING: Before starting, you must connect to a wifi network if NinerGuest unavailable."
sleep 5
DLNAME=jetson_linux_r36.3.0_aarch64.tbz2
OD=`pwd`
export MAKEFLAGS='-j'

sudo cp -r root/etc/NetworkManager/* /etc/NetworkManager/
sudo systemctl restart NetworkManager
sudo apt update
sudo apt install -y build-essential bc libdwarf-dev libncurses-dev vim htop locate libssl-dev nfs-kernel-server tftpd-hpa  isc-dhcp-server ntp firefox

#INITRD
cd initrd
sudo rm -rf root
mkdir -p root
cd root
sudo gzip -dc /boot/initrd | sudo cpio -idmv
sudo cp ../init .
sudo find . | sudo cpio -o -H newc | sudo gzip -9 > ${OD}/root/srv/tftp/initrd
cd $OD

# KERNEL
# this is  for jetpack 36.3. Will have to update this script in the future if we want to support future jetpacks; not sure
# how consistent the naming conventions are
dl_url=https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/release/${DLNAME}

if [[ ! -f ${DLNAME} ]]; then
	wget ${dl_url}
fi
tar xvf ${DLNAME}
cd Linux_for_Tegra/source
printf "jetson_36.3\njetson_36.3\n" | ./source_sync.sh

cp ${OD}/kernel/.config kernel/kernel-jammy-src/
cp ${OD}/kernel/Makefile kernel/

mkdir -p kernel_out
./nvbuild.sh -o kernel_out
#TODO check this actually replaces /boot/Image and /boot/initrd
sudo ./nvbuild.sh -i
cp /boot/Image ${OD}/root/srv/tftp/Image
cd $OD


# this will do apt update
yes | sudo unminimize
sudo systemctl enable nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp
sudo updatedb

sudo mkdir -p /etc/exports.d

# copy configs over
sudo cp -r root/* /

# ***hopefully*** persistent routing
sudo ip route add 192.168.0.0/24 dev eth0

# lets demo use nopasswd and gives dhcp permission to run its one script.
echo -e "demo ALL=(ALL) NOPASSWD: ALL\ndhcpd ALL=(ALL) NOPASSWD: /etc/dhcp/create_client_dirs.sh" | sudo tee /etc/sudoers.d/99-custom-sudoers
sudo chmod 0440 /etc/sudoers.d/99-custom-sudoers


sudo systemctl restart nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp

echo "Finished setup without errors. Reboot to reflect changes..."
