#!/bin/bash
# This script built and tested using CentOS 7. Other distributions or releases may or may not work.
# Script must be run by a user with sudo permission.  If sudo requires a password, user must enter it when executing.
# Example use: createlvm /dev/sdc /media/mount2
# Warning: Script will delete any partitions on specified device!

# Running the script without args could be dangerous, let's abort if no arguments are passed to the script
if [[ $# -eq 0 ]] ; then
        echo 'You must provide a device name and mount path, i.e. createlvm /dev/sdb /media/mount1'
        exit 0
fi
# Create the partition using fdisk and set the partition type to 8e(Linux LVM). Delete any existing partition table and make a single part for the whole disk:

(echo o; echo n; echo p; echo 1; echo ; echo; echo t; echo 8e; echo w) | sudo fdisk $1

# Create a physical volume on $1 argument with 1 appended (/dev/sdb1)
vlum=${1}1
sudo pvcreate $vlum 

# Create a volume group with a random name.  Hopefully 5 random characters will be enough
rand=$(date +%s | sha256sum | base64 | head -c 5)
vgname=vg_${rand}
sudo vgcreate $vgname $vlum

# Create the logical volume on the created volume group
lvname=lv_${rand}
sudo lvcreate -l 100%FREE -v $vgname -n $lvname

# Create the file system as ext4
sudo mke2fs -t ext4 /dev/${vgname}/${lvname}

# Create the mount point
sudo mkdir -p $2

# Mount the newly created volume at the mount point
sudo mount -o rw /dev/${vgname}/${lvname} $2