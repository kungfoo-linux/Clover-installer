#!/usr/bin/env python

import os
import sys

portage = "http://ftp.osuosl.org/pub/funtoo/funtoo-current/snapshots/portage-latest.tar.xz"

def portage():
	#PORTAGE SETUP
	#os.system('cd usr && wget %s' % portage)
	#os.system('tar xJpf portage-latest.tar.xz && rm portage-latest.tar.xz')
	#os.system('cd /usr/portage && git checkout funtoo.org')
	os.system('emerge --sync')
	basecompile = raw_input('Would you like to recompile the base system upto date? (recommended) y/n: ')
	if basecompile == 'y' or 'yes':
		os.system('emerge -uDN world')
	

def time():
	#TIMEZONE CONF
	tz = raw_input('What is your timezone? ex. America/Los_Angeles ')
	os.system('ln -sf /usr/share/zoneinfo/%s /etc/localtime' % tz)

def fstab():
	#FSTAB PARTITION CONF
	cont = raw_input('Press enter to edit your fstab.. ')
	os.system('nano /etc/fstab')


def hostname():
	#HOSTNAME CONF
	cont = raw_input('Press enter to edit your hostname.. ')
	os.system('nano /etc/conf.d/hostname')

def kernel():
	#KERNEL
	kernel = raw_input('What kernel do you wish to use? vanilla/gentoo/pf/ck/tuxonice :')
	if kernel == "gentoo":
		os.system('emerge -g gentoo-sources genkernel')
	elif kernel == "pf":
		os.system('emerge -g pf-sources genkernel')
	elif kernel == "ck":
		os.system('emerge -g ck-sources genkernel')
	elif kernel == "tuxonice":
		os.system('emerge -g tuxonice-sources genkernel')
	else:
		os.system('emerge -g vanilla-sources genkernel')
	print '** Compiling Kernel **'
	os.system('genkernel all')
	print '** Completed **'

def boot():
	#BOOT SETUP/CONF
	os.system('emerge boot-update')
	os.system('grub-install --no-floppy /dev/sda')
	os.system('mv /boot.conf /etc/boot.conf')
	os.system('boot-update')


def network():
	#NETWORK SETUP
	net = raw_input('Are you using wifi or wired connection? wifi/wired ')
	if net == 'wifi':
		os.system('emerge linux-firmware networkmanager')
		os.system('rc-update add NetworkManager default')
	else:
		os.system('rc-update add dhcpcd default')

def gui():
	#GUI SETUP
	gpu = raw_input('What graphics driver is expected? nouveau/nvidia/radeon/fglrx/vbox/fbdev/vesa/vmware ')
	os.system('echo "VIDEO_CARDS=\"%s\"" >> /etc/portage/make.conf' % gpu)
	os.system('echo "USE=\"alsa gdu git gtk introspection jpeg openal png sdl subversion svg -mono -gnome -kde -qt3 -qt4\"" >> /etc/portage/make.conf')
	os.system('echo "mate-base/mate -bluetooth -themes -extras" >> /etc/portage/package.use')
	os.system('echo "x11-misc/lightdm gtk -introspection -kde -qt4" >> /etc/portage/package.use')
	os.system('echo "sys-auth/consolekit policykit" >> /etc/portage/package.use')
	os.system('mv ./package.accept_keywords /etc/portage/')#Used to update Mate to 1.8
	#ASK FOR EDITING OF PORTAGE BEFORE COMPILE
	make = raw_input('Would you like to view and edit the make.conf before compiling the gui realated libraries? y/n ')
	if make == 'y' or 'yes':
		os.system('nano /etc/make.conf')
	os.system('emerge xorg-server mate lightdm')
	os.system('rc-update add xdm default') #xdm or lightdm???	
	os.system("sed -i 's/DISPLAYMANAGER=\".*\"/DISPLAYMANAGER=\"lightdm\"/g' /etc/conf.d/xdm")

def theme():
	#os.system('emerge gtk-theme?')
	os.system('emerge mate-icon-theme-faenza')
	os.system('gsettings set org.mate.interface gtk-theme \'what ever the fuck the theme is\'')
	os.system('gsettings set org.mate.interface icon-theme \'matefaenzadark\'')

def user():
	#USER/PASS SETUP
	os.system('clear')
	print 'What will the root password be?'
	os.system('passwd')
	user = raw_input('What will your username be? ')
	os.system("useradd -m -g users -G audio,video,cdrom,wheel,portage %s" % user)
	os.system('passwd %s' % user)
	

def main():
	portage()
	time()
	fstab()
	hostname()
	kernel()
	boot()
	network()
	gui()
	theme()
	user()

if __name__ == '__main__':
	main()
