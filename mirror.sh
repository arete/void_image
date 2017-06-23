xbps-install -Syu -R https://repo.voidlinux.eu/current/ -r /root/void/root -c /root/void/cache base-system etckeeper grub 


cd cache
xbps-rindex -a *.xbps
cd - 

