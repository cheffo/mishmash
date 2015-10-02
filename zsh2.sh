mount -t devfs devfs /dev
echo 'zfs_enable="YES"' >> /etc/rc.conf
echo 'zfs_load="YES"' >> /boot/loader.conf
zfs set readonly=on zroot/var/empty
zpool set cachefile=/boot/zfs/zpool.cache   zroot
