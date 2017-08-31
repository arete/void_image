mkdir -p cache root


xbps-install -Syu -R https://repo.voidlinux.eu/current/ -r /root/void/root -c /root/void/cache base-system etckeeper grub  samba dovecot dovecot-plugin-pigeonhole dovecot-plugin-lucene dovecot-plugin-sqlite fetchmail openldap postgresql postgresql-client php-pgsql nginx php php-fpm


cd cache
xbps-rindex -a *.xbps
cd - 

