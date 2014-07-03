#!/bin/bash

#########################
maindir=/mnt/clover
bootdir=/mnt/clover/boot
i686=http://ftp.iinet.net.au/linux/Gentoo/releases/x86/autobuilds/current-stage3-i686/stage3-i686-20140603.tar.bz2
i686uclibc=http://ftp.iinet.net.au/linux/Gentoo/releases/x86/autobuilds/current-stage3-i686-uclibc-vanilla/stage3-i686-uclibc-vanilla-20140605.tar.bz2
amd64=http://ftp.iinet.net.au/linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20140619.tar.bz2
amd64uclibc=http://ftp.iinet.net.au/linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-uclibc-vanilla/stage3-amd64-uclibc-vanilla-20140605.tar.bz2
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

echo "What architecture are you using? i686/i686-uclibc/amd64/amd64-uclibc: \c"
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
mkdir $bootdir
mount $boot $bootdir
echo "** Finished **"

#Edit
echo "** Copying needed files **"
cp ./1-chroot.sh $maindir
cp ./package.accept_keywords $maindir
echo "** Finished **"

#Stage3
cd $maindir
echo "** Grabbing stage3 **"

if [ "$arch" == "amd64-uclibc" ]; then
wget -q $amd64uclibc
elif [ "$arch" == "amd64" ]; then
wget -q $amd64
elif [ "$arch" == "i686-uclibc" ]; then
wget -q $i686uclibc
else
wget -q $i686
fi
echo "** Extracting stage3 **"
tar xvjpf stage3*
tar xvjpf current-stage3*
echo "** Finished **"

if [ "$arch" == "amd64-uclibc" ] || [ "$arch" == "amd64" ]; then
echo "ACCEPT_KEYWORDS=\"~amd64\"" >> etc/portage/make.conf
elif [ "$arch" == "i686-uclibc" ]; then
echo "ACCEPT_KEYWORDS=\"~x86\"" >> etc/portage/make.conf
else
echo "ACCEPT_KEYWORDS=\"~x86\"" >> etc/portage/make.conf
fi

#Chroot
echo "** Mounting **"
mount -t proc none proc
mount --rbind /sys sys
mount --rbind /dev dev
cp -L /etc/resolv.conf etc/
echo "** Finished **"
clear
echo "Now run 1-chroot.py to continue the installation process"
chroot $maindir /bin/bash

#Unmount
echo "** Unmounting **"
cd /mnt
umount -l clover
echo "** Finished **"
