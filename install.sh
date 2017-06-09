ROOT=/root/void/mnt
DEVICE=/dev/sdb
REPO=/root/void/cache

grep $ROOT /proc/mounts >/dev/null || exit

#installing
xbps-install -Syu -R $REPO -r $ROOT perl base-system   grub etckeeper

#mout
mount --rbind /sys $ROOT/sys 
mount --rbind /proc $ROOT/proc
mount --rbind /dev $ROOT/dev
#chroot
chroot $ROOT chmod 755 /
chroot $ROOT chown root:root /
chroot $ROOT etckeeper init
chroot $ROOT etckeeper commit "Initial commit" 
#ssh services
#ln -sf /etc/sv/sshd $ROOT/var/service
#ln -sg /etc/sv/uuidd $ROOT/var/service
chroot $ROOT sh -c 'echo "Void64Linux" > /etc/hostname'
#copy ssh ed25519.pub

#root passowrd
chroot $ROOT sh -c 'echo "root:voidlinux" | chpasswd -c SHA512'

chroot $ROOT sh -c 'echo "LANG=en_US.UTF-8" > /etc/locale.conf'
chroot $ROOT sh -c 'echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales'
chroot $ROOT sh -c 'echo "KEYMAP=it" >> /etc/rc.conf'
#chroot $ROOT sh -c "echo 'TIMEZONE="Europe/Rome"' >> /etc/rc.conf"
chroot $ROOT sh -c 'xbps-reconfigure -f glibc-locales'
chroot $ROOT sh -c 'echo "hostonly=yes" > /etc/dracut.conf.d/hostonly.conf'
KERNEL=$(chroot $ROOT sh -c "xbps-query --regex -s 'linux.\..'|cut -d ' ' -f 2|head -1|cut -d '-' -f 1")

chroot $ROOT sh -c "xbps-reconfigure -f $KERNEL" 
chroot $ROOT sh -c "grub-install $DEVICE"
chroot $ROOT sh -c 'grub-mkconfig -o /boot/grub/grub.cfg'



#umount
grep $ROOT /proc/mounts | cut -f2 -d" " | sort -r | xargs umount -n

