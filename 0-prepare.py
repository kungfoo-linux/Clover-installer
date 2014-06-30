#!/usr/bin/env python

import os
import subprocess
import sys


print 'It is expected that you have already partitioned your drives'
print 'A boot partition'
print 'A swap partition'
print 'And a root partition'
print ''
cont = raw_input('Type "exit" if you have not partitioned your drive yet or press Enter if you wish to proceed... ')
if cont == "exit":
	sys.exit()
os.system('clear')

maindir = '/mnt/clover'
boot = raw_input('What is your boot partition? ')
swap = raw_input('What is your swap partition? ')
root = raw_input('What is your root partition? ')
stage332 = "http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-32bit/generic_32/stage3-latest.tar.xz"
stage364 = "http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-64bit/generic_64/stage3-latest.tar.xz"
stage3i7 = "http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-64bit/corei7/stage3-latest.tar.xz"
arch = raw_input('What architecture are you using? 32-bit/64-bit/i7-64-bit: ')

def fs():
	subprocess.call(['mkfs.ext2', boot])
	subprocess.call(['mkfs.xfs', root])
	subprocess.call(['mkswap', swap])
	subprocess.call(['swapon', swap])

def directory():
	print '** Creating directories **'
	os.system('mkdir /mnt/clover')
	os.system('mount %s %s' % (root, maindir))
	os.system('mkdir /mnt/clover/boot')
	os.system('mount %s /mnt/clover/boot' % boot )
	print '** Finished **'

def edit():
	print '** Copying needed files **'
	os.system('cp ./1-chroot.py %s' % maindir)
	os.system('cp ./boot.conf %s' % maindir)
	os.system('cp ./package.accept_keywords %s' % maindir)
	#os.system('cp ./clover.xml %s' % maindir)
	print '** Finished **'

def stage3():
	os.chdir(maindir)
	print '** Grabbing stage3 **'
	if arch == 'i7-64-bit':
		os.system('wget -q %s' % stage3i7)
	if arch == '64-bit':
		os.system('wget -q %s' % stage364)
	else:
		os.system('wget -q %s' % stage332)
	print '** Finished **'
	print '** Extracting stage3 **'
	os.system('tar xpvf stage3-latest.tar.xz')
	print '** Finished **'

def chroot():
	#CHROOT SETUP
	os.chdir(maindir)
	print '** Mounting **'
	os.system('mount --bind /dev dev/')
	os.system('mount --bind /sys sys/')
	os.system('mount --bind /proc proc/')
	os.system('cp /etc/resolv.conf etc/')
	print '** Finished **'
	os.system('clear')
	print 'Now run 1-chroot.py to continue the installation process'
	os.system('chroot %s /bin/bash' % maindir)

def umount():
	print '** Unmounting **'
	os.system('umount /mnt/clover/{proc,sys,dev,boot} /mnt/clover')
	print '** Finished **'

def main():
	fs()
	directory()
	edit()
	stage3()
	chroot()
	umount()				

if __name__ == '__main__':
	main()
else:
	sys.exit()

