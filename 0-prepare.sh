#!/bin/bash

#########################
maindir=/mnt/clover
stage332=http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-32bit/generic_32/stage3-latest.tar.xz
stage364=http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-64bit/generic_64/stage3-latest.tar.xz
stage3i7=http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-64bit/corei7/stage3-latest.tar.xz
#########################

clear
echo "It is expected that you have already partitioned your drives"
echo "A boot partition"
echo "A swap partition"
echo "And a root partition"
echo \n
echo "Exit if you have not partitioned your drive yet or press Enter if you wish to proceed... \c"
read enter
clear

echo "What is your boot partition? \c"
read boot
echo "What is your swap partition? \c"
read swap
echo "What is your root partition? \c"
read root
clear

echo "What architecture are you using? 32-bit/64-bit/i7-64-bit: \c"
read arch

#Format
mkfs.ext2 $boot
mkfs.xfs -f $root
mkswap $swap
swapon $swap

#Directory
echo "** Creating directories **"
mkdir $maindir
mount $root $maindir
mkdir /mnt/clover/boot
mount $boot /mnt/clover/boot
echo "** Finished **"

#Edit
echo "** Copying needed files **"
cp ./1-chroot.sh $maindir
cp ./boot.conf $maindir
cp ./package.accept_keywords $maindir
#cp ./clover.xml $maindir
echo "** Finished **"

#Stage3
cd $maindir
echo "** Grabbing stage3 **"

if [ "$arch" == "i7-64-bit" ]; then
	wget -q $stage3i7
elif [ "$arch" == "64-bit" ]; then
	wget -q $stage364
else
	wget -q $stage332
fi
echo "** Extracting stage3 **"
tar xpvf stage3-latest.tar.xz
echo "** Finished **"

#Chroot
echo "** Mounting **"
mount --bind /dev dev/
mount --bind /sys sys/
mount --bind /proc proc/
cp -L /etc/resolv.conf etc/
echo "** Finished **"
clear
echo "Now run 1-chroot.py to continue the installation process"
chroot $maindir /bin/bash

#Unmount
echo "** Unmounting **"
umount /mnt/clover/{proc,sys,dev,boot} /mnt/clover
echo "** Finished **"
