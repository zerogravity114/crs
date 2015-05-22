#!/bin/bash
# This script built and tested using CentOS 7. Other distributions or releases may or may not work.
# Script must be run with root permissions.
# Example use: sudo createlvm /dev/sdc /media/mount2
# Warning: Script will delete any partitions on specified device!

# Running the script without args could be dangerous, let's abort if no arguments are passed to the script
if [[ $# -eq 0 ]] ; then
        echo 'You must provide a device name and mount path, i.e. createlvm /dev/sdb /media/mount1'
        exit 0
fi
# Create the partition using fdisk and set the partition type to 8e(Linux LVM). Delete any existing partition table and make a single part for the whole disk:

(echo o; echo n; echo p; echo 1; echo ; echo; echo t; echo 8e; echo w) | fdisk $1

# Create a physical volume on $1 argument with 1 appended (/dev/sdb1)
vlum=${1}1
pvcreate $vlum 

# Create a volume group with a random name.  Hopefully 5 random characters will be enough
rand=$(date +%s | sha256sum | base64 | head -c 5)
vgname=vg_${rand}
vgcreate $vgname $vlum

# Create the logical volume on the created volume group
lvname=lv_${rand}
lvcreate -l 100%FREE -v $vgname -n $lvname

# Create the file system as ext4
mke2fs -t ext4 /dev/${vgname}/${lvname}

# Create the mount point
mkdir -p $2

# Mount the newly created volume at the mount point
mount -o rw /dev/${vgname}/${lvname} $2

# Add an entry to /etc/fstab so the LVM mounts at boot time
echo "/dev/mapper/${vgname}-${lvname} $2	ext4	defaults	1 1" | tee -a /etc/fstab
