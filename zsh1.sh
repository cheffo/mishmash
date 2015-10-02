sysctl kern.geom.debugflags=16

zpool import -f -o altroot=/mnt zroot
zpool destroy zroot

echo gpart destroy
gpart destroy -F ada0
gpart destroy -F ada1
gpart destroy -F ada2
gpart destroy -F ada3

echo gpart create
gpart create -s gpt ada0
gpart create -s gpt ada1
gpart create -s gpt ada2
gpart create -s gpt ada3

echo gpart add and boot ada0
gpart add -s 512 -a 4k -t freebsd-boot -l boot0 ada0
gpart add -s 5g -a 4k -t freebsd-zfs -l disk0 ada0
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0

echo gpart add and boot ada1
gpart add -s 512 -a 4k -t freebsd-boot -l boot1 ada1
gpart add -s 5g -a 4k -t freebsd-zfs -l disk1 ada1
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada1

echo gpart add and boot ada2
gpart add -s 512 -a 4k -t freebsd-boot -l boot2 ada2
gpart add -s 5g -a 4k -t freebsd-zfs -l disk2 ada2
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada2

echo gpart add and boot ada3
gpart add -s 512 -a 4k -t freebsd-boot -l boot3 ada3
gpart add -s 5g -a 4k -t freebsd-zfs -l disk3 ada3
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada3

echo 4k align autoashift
sysctl vfs.zfs.min_auto_ashift=12

echo create pool
zpool create -o altroot=/mnt -O canmount=off -m none zroot raidz /dev/gpt/disk0 /dev/gpt/disk1 /dev/gpt/disk2 /dev/gpt/disk3

echo zfs stuff
zfs set checksum=fletcher4                                           zroot
zfs set atime=off                                                    zroot

echo ZFS root
zfs create   -o mountpoint=none                                      zroot/ROOT
zfs create   -o mountpoint=/                                         zroot/ROOT/default
zfs create   -o mountpoint=/tmp -o compression=lz4  -o setuid=off   zroot/tmp
chmod 1777 /mnt/tmp

echo ZFS other filesystems
zfs create   -o mountpoint=/usr                                      zroot/usr
zfs create                                                           zroot/usr/local

zfs create   -o mountpoint=/home                     -o setuid=off   zroot/home
zfs create   -o compression=lz4                     -o setuid=off   zroot/usr/ports
zfs create   -o compression=off      -o exec=off     -o setuid=off   zroot/usr/ports/distfiles
zfs create   -o compression=off      -o exec=off     -o setuid=off   zroot/usr/ports/packages
zfs create   -o compression=lz4     -o exec=off     -o setuid=off   zroot/usr/src
zfs create                                                           zroot/usr/obj
zfs create   -o mountpoint=/var                                      zroot/var
zfs create   -o compression=lz4     -o exec=off     -o setuid=off   zroot/var/crash
zfs create                           -o exec=off     -o setuid=off   zroot/var/db
zfs create   -o compression=lz4     -o exec=on      -o setuid=off   zroot/var/db/pkg
zfs create                           -o exec=off     -o setuid=off   zroot/var/empty
zfs create   -o compression=lz4     -o exec=off     -o setuid=off   zroot/var/log
zfs create   -o compression=gzip     -o exec=off     -o setuid=off   zroot/var/mail
zfs create                           -o exec=off     -o setuid=off   zroot/var/run
zfs create   -o compression=lz4     -o exec=on      -o setuid=off   zroot/var/tmp
chmod 1777 /mnt/var/tmp

echo set zfs bootfs
zpool set bootfs=zroot/ROOT/default zroot
