
CONFIG=$1
CONFIG_FILE=$CONFIG/config
if [ ! -f "${CONFIG_FILE}" ]; then
        echo "${CONFIG_FILE} not is  a file";
	exit
fi
. $CONFIG_FILE


mkfs.ext4 $ROOT_DEVICE -F
mount $ROOT_DEVICE $ROOT


grep $ROOT /proc/mounts >/dev/null || exit

#installing
xbps-install -Syu -R $REPO -r $ROOT  base-system  grub etckeeper  samba || exit

#mout
mount --rbind /sys $ROOT/sys 
mount --rbind /proc $ROOT/proc
mount --rbind /dev $ROOT/dev
#chroot
chroot $ROOT chmod 755 /
chroot $ROOT chown root:root /
chroot $ROOT etckeeper init
chroot $ROOT etckeeper commit "Initial commit" 
#enable services
SERVICEDIR=$ROOT/etc/sv
for f in ${SERVICES}; do
        ln -sf /etc/sv/$f $ROOT/etc/runit/runsvdir/default/
done

#overlay
cp -dpR $CONFIG/overlay/* $ROOT 
echo "HostKvm" > $ROOT/etc/hostname
#copy ssh ed25519.pub

#root passowrd
chroot $ROOT sh -c 'echo "root:voidlinux" | chpasswd -c SHA512'
chroot $ROOT sh -c 'chsh -s /bin/bash root'
chroot $ROOT sh -c 'echo "LANG=en_US.UTF-8" > /etc/locale.conf'
chroot $ROOT sh -c 'echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales'
chroot $ROOT sh -c 'echo "KEYMAP=it" >> /etc/rc.conf'
chroot $ROOT sh -c "echo 'TIMEZONE="Europe/Rome"' >> /etc/rc.conf"
chroot $ROOT sh -c 'xbps-reconfigure -f glibc-locales'
#chroot $ROOT sh -c 'echo "hostonly=yes" > /etc/dracut.conf.d/hostonly.conf'
#network config
chroot $ROOT sh -c "echo 'ip link set dev $NET_DEVICE up' >>/etc/rc.local"
chroot $ROOT sh -c "echo 'ip addr add $NET_IP dev $NET_DEVICE' >>/etc/rc.local"
chroot $ROOT sh -c "echo 'ip route add default via $NET_ROUTER' >> etc/rc.local"
chroot $ROOT sh -c "echo 'nameserver $NET_DNS'>/etc/resolv.conf"

KERNEL=$(chroot $ROOT sh -c "xbps-query --regex -s 'linux.\..'|cut -d ' ' -f 2|head -1|cut -d '-' -f 1")

chroot $ROOT sh -c "xbps-reconfigure -f $KERNEL" 
#chroot $ROOT sh -c "grub-install --target=i386-pc  $DEVICE"

echo "(hd0) $DEVICE" > $ROOT//boot/device.map
echo "GRUB_DISABLE_OS_PROBER=true" | tee -a $ROOT/etc/default/grub
chroot $ROOT grub-install --no-floppy --grub-mkdevicemap=/boot/device.map  --modules="biosdisk part_msdos ext2 configfile normal multiboot" --target=i386-pc $DEVICE 

chroot $ROOT sh -c 'grub-mkconfig -o /boot/grub/grub.cfg'



#umount
grep $ROOT /proc/mounts | cut -f2 -d" " | sort -r | xargs umount -n

