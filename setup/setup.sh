#!/bin/bash -xe

OD=`pwd`
MAJOR=36
MINOR=3
REV=0
GIT_TAG=jetson_${MAJOR}.${MINOR}
DLNAME=jetson_linux_r${MAJOR}.${MINOR}.${REV}_aarch64.tbz2
dl_url=https://developer.nvidia.com/downloads/embedded/l4t/r${MAJOR}_release_v${MINOR}.${REV}/release/${DLNAME}
export MAKEFLAGS='-j'

echo "Starting system setup for Jetson Orin Nano - Jetpack Version ${MAJOR}.${MINOR}.${REV}."
echo "Update environment variables in this script to try a new version (untested)."
echo "Do not run this script as root."
echo "You will have to enter sudo password exactly once after this message."
echo "WARNING: Before starting, you must connect to a WiFi network; Eduroam is sufficient, NinerGuest is not."
sleep 10

# lets demo use nopasswd and gives dhcp permission to run its one script.
echo -e "`whoami` ALL=(ALL) NOPASSWD: ALL\ndhcpd ALL=(ALL) NOPASSWD: /etc/dhcp/create_client_dirs.sh" | sudo tee /etc/sudoers.d/99-custom-sudoers
sudo chmod 0440 /etc/sudoers.d/99-custom-sudoers
nmcli con mod 'Wired connection 1' ifname eth0 ipv4.addresses 192.168.0.10/24 ipv4.method manual

# ***hopefully*** persistent routing
sudo ip route add 192.168.0.0/24 dev eth0

sudo apt update
sudo apt install -y build-essential bc libdwarf-dev libncurses-dev vim htop locate libssl-dev nfs-kernel-server tftpd-hpa  isc-dhcp-server ntp firefox mpich libglew-dev libglfw3-dev libfreetype-dev libxxf86vm-dev libxi-dev

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
if [[ ! -f ${DLNAME} ]]; then
	wget ${dl_url}
fi
tar xvf ${DLNAME}
cd Linux_for_Tegra/source
printf "${GIT_TAG}\n${GIT_TAG}\n" | ./source_sync.sh

cp ${OD}/kernel/.config kernel/kernel-jammy-src/
cp ${OD}/kernel/Makefile kernel/

mkdir -p kernel_out
./nvbuild.sh -o kernel_out
#TODO check this actually replaces /boot/Image and /boot/initrd
sudo ./nvbuild.sh -i
cp /boot/Image ${OD}/root/srv/tftp/Image
cd $OD

# Add man pages back
yes | sudo unminimize
sudo systemctl enable nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp

# NFS 
sudo mkdir -p /etc/exports.d

# copy configs over
sudo cp -r root/* /
sudo chown dhcpd:dhcpd /etc/dhcp/create_client_dirs_wrapper.sh
sudo chmod 744 /etc/dhcp/create_client_dirs_wrapper.sh /etc/dhcp/create_client_dirs.sh

# check services work
sudo systemctl restart nfs-kernel-server tftpd-hpa isc-dhcp-server  NetworkManager-wait-online.service ntp
# index files for search later
sudo updatedb

# docker screws up mpi; can fix later maybe
sudo systemctl disable docker

echo "Finished setup without errors. Reboot to reflect changes..."
