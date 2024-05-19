#!/bin/bash

# Script to create client directories, assign hostname, generate fstab, and disable services
IP_ADDRESS=$1
MAC_ADDRESS=$2
#MAC_ADDRESS=$(echo $2 | tr ':' '-')
echo $2
echo $MAC_ADDRESS

echo "above are the hardware args to dhcpd"
LAST_TWO_DIGITS=$3
BASE_DIR="/srv/nfs_client_dirs/${MAC_ADDRESS}/"
ETC_DIR="${BASE_DIR}/etc"
VAR_DIR="${BASE_DIR}/var"
TMP_DIR="${BASE_DIR}/tmp"
HOSTNAME="demo${LAST_TWO_DIGITS}"
NFS_SERVER="192.168.0.10"

# Ensure base directories exist
#mkdir -p ${ETC_DIR}
#mkdir -p ${VAR_DIR}
#mkdir -p ${BASE_DIR}

# creates basedir and tmp dir if they don't exist
mkdir -p ${TMP_DIR} 

# Copy /etc /var contents to client-specific directory if not already copied
if [ ! -d "${VAR_DIR}" ]; then
    cp -a /var/ ${VAR_DIR} &
fi
if [ ! -d "${ETC_DIR}" ]; then
    cp -a /etc/ ${ETC_DIR}
fi

# Set the hostname in the copied /etc directory
echo "${HOSTNAME}" > ${ETC_DIR}/hostname
echo "127.0.0.1 localhost" > ${ETC_DIR}/hosts
echo "127.0.1.1 ${HOSTNAME}" >> ${ETC_DIR}/hosts

echo -e "[Time]\nNTP=192.168.0.10" > ${ETC_DIR}/systemd/timesyncd.conf

# Disable TFTP and DHCP servers on the client by removing symlinks
rm -f ${ETC_DIR}/systemd/system/multi-user.target.wants/isc-dhcp-server.service
rm -f ${ETC_DIR}/systemd/system/multi-user.target.wants/tftpd-hpa.service
rm -f ${ETC_DIR}/systemd/system/multi-user.target.wants/nfs-kernel-server.service
rm -f ${ETC_DIR}/systemd/system/multi-user.target.wants/nfs-server.service
rm -f ${ETC_DIR}/systemd/system/multi-user.target.wants/nv.service
rm -f ${ETC_DIR}/init.d/nfs-kernel-server
rm -f ${ETC_DIR}/init.d/tftpd-hpa
rm -f ${ETC_DIR}/init.d/isc-dhcp-server
rm -f ${ETC_DIR}/fstab
rm -f ${ETC_DIR}/exports
rm -rf ${ETC_DIR}/exports.d/

find ${ETC_DIR}/NetworkManager/system-connections/ -type f ! -name 'Wired connection 1.nmconnection' -exec rm -f '{}' \;

echo -e "/srv/nfs_client_dirs/${MAC_ADDRESS}/etc ${IP_ADDRESS}(rw,async,no_root_squash,no_all_squash,no_subtree_check,insecure,anonuid=1000,anongid=1000)\n\
/srv/nfs_client_dirs/${MAC_ADDRESS}/tmp ${IP_ADDRESS}(rw,async,no_root_squash,no_all_squash,no_subtree_check,insecure,anonuid=1000,anongid=1000)\n\
/srv/nfs_client_dirs/${MAC_ADDRESS}/var ${IP_ADDRESS}(rw,async,no_root_squash,no_all_squash,no_subtree_check,insecure,anonuid=1000,anongid=1000)" > /etc/exports.d/${MAC_ADDRESS}.exports

exportfs -ra
wait
