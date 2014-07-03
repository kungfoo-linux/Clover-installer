#!/bin/bash

portage=http://ftp.osuosl.org/pub/funtoo/funtoo-current/snapshots/portage-latest.tar.xz

#Startup
export PS1="(chroot) $PS1"
env-update

#Portage setup
echo "SYNC=\"rsync://rsync.au.gentoo.org/gentoo-portage\"" >> /etc/portage/make.conf
echo "GENTOO_MIRRORS=\"ftp://ftp.iinet.com.au/linux/Gentoo ftp://ftp.swin.edu.au/gentoo\"" >> /etc/portage/make.conf
emerge-webrsync
emerge --oneshot portage
emerge --sync

echo "USE=\"alsa gdu git gtk introspection X -branding -mono -gnome -kde -qt3 -qt4\"" >> /etc/portage/make.conf
echo "mate-base/mate -bluetooth -themes -extras" >> /etc/portage/package.use/clover
echo "x11-misc/lightdm gtk introspection -kde -qt4" >> /etc/portage/package.use/clover
echo "sys-auth/consolekit policykit" >> /etc/portage/package.use/clover
mv ./package.accept_keywords /etc/portage/ #Used to update Mate to 1.8

echo "Would you like to recompile the base system upto date? y/n: \c"
read basecompile
if [ "$basecompile" == "y" ] || [ "$basecompile" == "yes" ]; then
	emerge -uDN world
fi	

#Time
echo "What is your timezone? ex. America/Los_Angeles \c"
read tz
echo "$tz" > /etc/timezone

#Fstab
echo "Press enter to edit your fstab.. "
read cont
nano -w /etc/fstab

#Hostname
echo "What will your hostname be? \c"
read host
sed -i "s/hostname=.*/hostname=\"$host\"/g" /etc/conf.d/hostname

#Kernel
echo "What kernel do you wish to use? vanilla/gentoo/pf/ck/tuxonice :\c"
read kernel
if [ "$kernel" == "gentoo" ]; then
	emerge -g gentoo-sources genkernel
elif [ "$kernel" == "pf" ]; then
	emerge -g pf-sources genkernel
elif [ "$kernel" == "ck" ]; then
	emerge -g ck-sources genkernel
elif [ "$kernel" == "tuxonice" ]; then
	emerge -g tuxonice-sources genkernel
else
	emerge -g vanilla-sources genkernel
fi
echo "** Compiling Kernel **"
genkernel all
echo "** Completed **"

#Boot
emerge sys-boot/grub:2 sys-boot/os-prober sys-fs/ntfs3g
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

#Network
echo "Are you using wifi or wired connection? wifi/wired \c"
read net
if [ $net == "wifi" ]; then
	emerge linux-firmware networkmanager
	rc-update add NetworkManager default
else
	rc-update add dhcpcd default
fi

#Make.conf setup
echo "What graphics driver is expected? nouveau/nvidia/radeon/fglrx/vbox/fbdev/vesa/vmware/intel \c"
read gpu
echo "VIDEO_CARDS=\"$gpu\"" >> /etc/portage/make.conf
echo "Would you like to view and edit the make.conf before compiling the gui related libraries? y/n \c"
read make
if [ "$make" == "y" ] || [ "$make" == "yes" ]; then
	nano /etc/make.conf
fi

#Gui
emerge xorg-server mate lightdm
rc-update add dbus default
rc-update add xdm default
sed -i "s/DISPLAYMANAGER=\".*\"/DISPLAYMANAGER=\"lightdm\"/g" /etc/conf.d/xdm

#Theme
#emerge gtk-theme?
emerge mate-icon-theme-faenza
#gsettings set org.mate.interface gtk-theme 'what ever the fuck the theme is'
gsettings set org.mate.interface icon-theme 'matefaenzadark'

#User/Pass
echo "What will the root password be?"
passwd
echo "What will your username be? \c"
read user
useradd -m -g users -G audio,video,cdrom,wheel,portage $user
passwd $user
