#!/bin/bash
set -e
set -u

echo "--"
echo "Parameters for the installation."
echo "--"
export TARGET_NFS_DIR="/srv/nfsroot/"
export TARGET_TFTP_DIR="/srv/tftp/"
export MIRROR="https://deb.debian.org/debian/"
export DISTRO="trixie"
export ARCH="amd64"
export ETH="enp0s3"

echo "--"
echo "Install packages that we need on the host system to install our PXE environment,"
echo "which includes dnsmasq as a dhcp-server, tftpd-hpa as a tftp-server, and"
echo "nfs for the network files system."
echo "--"
apt-get -y install debootstrap zip binutils coreutils util-linux e2fsprogs \
    dnsmasq tftpd-hpa tftp-hpa nfs-common nfs-kernel-server

mkdir -p ${TARGET_NFS_DIR}
mkdir -p ${TARGET_TFTP_DIR}

echo "--"
echo "Build a basic rootfs system (This takes a while)"
echo "--"
export DEBIAN_FRONTEND=noninteractive
debootstrap --verbose --extractor=ar --arch=${ARCH} ${DISTRO} ${TARGET_NFS_DIR} ${MIRROR}

echo "--"
echo "Setup apt-get configuration on the new rootfs."
echo "--"
cat > ${TARGET_NFS_DIR}/etc/apt/sources.list <<-EOT
deb ${MIRROR} ${DISTRO} main contrib non-free
deb-src ${MIRROR} ${DISTRO} main contrib non-free

deb http://security.debian.org/debian-security ${DISTRO}-security main contrib non-free
deb-src http://security.debian.org/debian-security ${DISTRO}-security main contrib non-free

EOT

echo "--"
echo "Setup the PXE network interfaces configuration. This is the configuration the"
echo "clients will use to bring up their network. Assumes that they have a single"
echo "LAN interface."
echo "--"
cat > ${TARGET_NFS_DIR}/etc/network/interfaces <<-EOT
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp
EOT

echo "--"
echo "Setup the nfs root in a way so we can chroot into it."
echo "--"
mount -t proc none ${TARGET_NFS_DIR}/proc
mount --bind /sys ${TARGET_NFS_DIR}/sys
mount --bind /dev ${TARGET_NFS_DIR}/dev
mount -t tmpfs none ${TARGET_NFS_DIR}/tmp

cp /etc/resolv.conf ${TARGET_NFS_DIR}/etc/resolv.conf
echo "--"
echo "Setup a hostname on the NFS root (This might confuse some applications, as"
echo "the hostname is random on each read)"
echo "--"
echo "pxeclient" > ${TARGET_NFS_DIR}/etc/hostname
echo "127.0.0.1 pxeclient" >> ${TARGET_NFS_DIR}/etc/hosts
# Setup /tmp as tmpfs on the netboot system, so we have a place to write
#   things to.
cat > ${TARGET_NFS_DIR}/etc/fstab <<-EOT
tmpfs /tmp  tmpfs  nodev,nosuid 0  0
EOT

echo "--"
echo "Get syslinux/pxelinux, which contains a lot of files, but we need some of"
echo "these to get PXE booting to work."
echo "--"
apt-get -y install pxelinux syslinux-efi
mkdir -p ${TARGET_TFTP_DIR}/efi32
mkdir -p ${TARGET_TFTP_DIR}/efi64
cp /usr/lib/PXELINUX/pxelinux.0 ${TARGET_TFTP_DIR}/
cp /usr/lib/syslinux/modules/bios/*.c32 ${TARGET_TFTP_DIR}/
cp /usr/lib/SYSLINUX.EFI/efi32/syslinux.efi ${TARGET_TFTP_DIR}/efi32/
cp /usr/lib/syslinux/modules/efi32/*.e32 ${TARGET_TFTP_DIR}/efi32/
cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi ${TARGET_TFTP_DIR}/efi64/
cp /usr/lib/syslinux/modules/efi64/*.e64 ${TARGET_TFTP_DIR}/efi64/

echo "--"
echo "Configure pxelinux."
echo "--"
mkdir -p ${TARGET_TFTP_DIR}/pxelinux.cfg
cat > ${TARGET_TFTP_DIR}/pxelinux.cfg/default <<-EOT
DEFAULT linux
LABEL linux
KERNEL vmlinuz.img
APPEND ro root=/dev/nfs nfsroot=192.168.55.1:${TARGET_NFS_DIR} initrd=initrd.img
EOT
# ln -sf ${TARGET_TFTP_DIR}/pxelinux.cfg ${TARGET_TFTP_DIR}/bios/pxelinux.cfg
# ln -sf ${TARGET_TFTP_DIR}/pxelinux.cfg ${TARGET_TFTP_DIR}/efi32/pxelinux.cfg
# ln -sf ${TARGET_TFTP_DIR}/pxelinux.cfg ${TARGET_TFTP_DIR}/efi64/pxelinux.cfg

# ln -sf ${TARGET_TFTP_DIR}/vmlinuz.img ${TARGET_TFTP_DIR}/bios/vmlinuz.img
# ln -sf ${TARGET_TFTP_DIR}/vmlinuz.img ${TARGET_TFTP_DIR}/efi32/vmlinuz.img
# ln -sf ${TARGET_TFTP_DIR}/vmlinuz.img ${TARGET_TFTP_DIR}/efi64/vmlinuz.img

# ln -sf ${TARGET_TFTP_DIR}/initrd.img ${TARGET_TFTP_DIR}/bios/initrd.img
# ln -sf ${TARGET_TFTP_DIR}/initrd.img ${TARGET_TFTP_DIR}/efi32/initrd.img
# ln -sf ${TARGET_TFTP_DIR}/initrd.img ${TARGET_TFTP_DIR}/efi64/initrd.img

echo "--"
echo "Setup vmlinuz.img kernel in ${TARGET_TFTP_DIR}"
echo "--"
chroot ${TARGET_NFS_DIR} apt-get update
chroot ${TARGET_NFS_DIR} apt-get -y install linux-image-${ARCH} # firmware-linux-nonfree
cp ${TARGET_NFS_DIR}/boot/vmlinuz* ${TARGET_TFTP_DIR}/vmlinuz.img
cp ${TARGET_NFS_DIR}/boot/initrd.img* ${TARGET_TFTP_DIR}/initrd.img

echo "--"
echo "Setup the export to the /etc/exports file, this will serve our root through"
echo "NFS after rebooting the system later."
echo "--"
cat > /etc/exports <<-EOT
${TARGET_NFS_DIR} *(ro,sync,no_root_squash,insecure)
EOT

echo "--"
echo "Setup the network interface to a static IP."
echo "--"
cat > /etc/network/interfaces <<-EOT
auto lo
iface lo inet loopback

allow-hotplug ${ETH}
auto ${ETH}
iface ${ETH} inet static
    address 192.168.55.1
    netmask 255.255.255.0
EOT

echo "--"
echo "Setup dnsmasq to serve as a DHCP server."
echo "--"
cat > /etc/dnsmasq.conf <<-EOT
interface=${ETH}
dhcp-range=192.168.55.10,192.168.55.254

dhcp-boot=pxelinux.0
EOT

echo "--"
echo "Disable some services to decrease boot time"
echo "--"
chroot ${TARGET_NFS_DIR} systemctl disable rsyslog

echo "--"
echo "Install tools in NFS root required to build EE."
echo "--"
chroot ${TARGET_NFS_DIR} apt-get update
chroot ${TARGET_NFS_DIR} apt-get -y install git build-essential libsdl2-dev \
    cmake ninja-build

echo "--"
echo "Install basic Xserver setup in NFS root to allow us to run EE later on."
echo "--"
chroot ${TARGET_NFS_DIR} apt-get -y install xserver-xorg-core \
    xserver-xorg-input-all xserver-xorg-video-all xinit alsa-utils mesa-utils

echo "--"
echo "Download, compile, and install EE and SP (this takes a while)"
echo "--"
chroot ${TARGET_NFS_DIR} git clone https://github.com/daid/EmptyEpsilon.git /root/EmptyEpsilon
chroot ${TARGET_NFS_DIR} git clone https://github.com/daid/SeriousProton.git /root/SeriousProton
mkdir -p ${TARGET_NFS_DIR}/root/EmptyEpsilon/_build
chroot ${TARGET_NFS_DIR} sh -c 'cd /root/EmptyEpsilon/_build && cmake .. -G Ninja -DSERIOUS_PROTON_DIR=$HOME/SeriousProton/ && ninja'

echo "--"
echo "Create a symlink for the final EE executable."
echo "--"
chroot ${TARGET_NFS_DIR} ln -sf _build/EmptyEpsilon /root/EmptyEpsilon/EmptyEpsilon

echo "--"
echo "Create a symlink to store the options.ini EE Preferences File in /tmp/,"
echo "so that each client can load a custom file."
echo "--"
chroot ${TARGET_NFS_DIR} ln -sf /tmp/options.ini /root/EmptyEpsilon/options.ini

echo "--"
echo "Set up the client configuration tool config_manager.py, which sets up"
echo "Preferences Files for each client."
echo "--"
cat > ${TARGET_NFS_DIR}/root/setup_option_file.sh <<-EOT
#!/bin/sh
MAC=\$(cat /sys/class/net/e*/address | head -n 1 | sed 's/://g')
if [ -e /root/configs/\${MAC}.ini ]; then
    cp /root/configs/\${MAC}.ini /tmp/options.ini
else
    echo "instance_name=\${MAC}" > /tmp/options.ini
    echo "username=\${MAC}" >> /tmp/options.ini
fi
EOT
chmod +x ${TARGET_NFS_DIR}/root/setup_option_file.sh
mkdir -p ${TARGET_NFS_DIR}/root/configs

ln -sf ${TARGET_NFS_DIR}/root/EmptyEpsilon/netboot/config_manager.py ~/config_manager.py

echo "--"
echo "Create and install a systemd unit that launches EE on the client."
echo "--"
cat > ${TARGET_NFS_DIR}/etc/systemd/system/emptyepsilon.service <<-EOT
[Unit]
Description=EmptyEpsilon

[Service]
Environment=XAUTHORITY=/tmp/.xauthority
TimeoutStartSec=0
WorkingDirectory=/root/EmptyEpsilon
ExecStartPre=/root/setup_option_file.sh
ExecStart=/usr/bin/startx /root/EmptyEpsilon/EmptyEpsilon -- -logfile /tmp/x.log

[Install]
WantedBy=multi-user.target
EOT
chroot ${TARGET_NFS_DIR} systemctl enable emptyepsilon.service

echo "--"
echo "Disable screen standby/blanking on the client."
echo "--"
mkdir -p ${TARGET_NFS_DIR}/etc/X11/xorg.conf.d
cat > ${TARGET_NFS_DIR}/etc/X11/xorg.conf.d/10-monitor.config <<-EOT
Section "Monitor"
    Identifier "LVDS0"
    Option "DPMS" "false"
EndSection

Section "ServerLayout"
    Identifier "ServerLayout0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime"     "0"
    Option "BlankTime"   "0"
EndSection
EOT

echo "--"
echo "Instead of running a login shell on tty1, run a normal shell so we don't"
echo "have to login with a username/password."
echo "--"
cat > ${TARGET_NFS_DIR}/etc/systemd/system/shell_on_tty.service <<-EOT
[Unit]
Description=Shell on TTY1
After=getty.target
Conflicts=getty@tty1.service

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/bin/bash
TimeoutStopSec=1
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=graphical.target
EOT
chroot ${TARGET_NFS_DIR} systemctl enable shell_on_tty.service

echo "--"
echo "Install an SSH server on clients so we can remotely access"
echo "them, and add a private key on the server and the public key as an authorized"
echo "key in the client. Also install avahi on the client for easier server discovery."
echo "--"
chroot ${TARGET_NFS_DIR} apt-get install -y openssh-server avahi-daemon avahi-utils libnss-mdns
echo "PermitRootLogin yes" >> ${TARGET_NFS_DIR}/etc/ssh/sshd_config
if [[ ! -e $HOME/.ssh/id_rsa ]]; then
    ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -N ''
fi
mkdir -p ${TARGET_NFS_DIR}/root/.ssh/
cp $HOME/.ssh/id_rsa.pub ${TARGET_NFS_DIR}/root/.ssh/authorized_keys
cat > ${TARGET_NFS_DIR}/etc/avahi/services/ee.service <<-EOT
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">EmptyEpsilon on %h</name>
  <service>
    <type>_emptyepsilon._tcp</type>
    <port>22</port>
  </service>
</service-group>
EOT

echo "--"
echo "Disable a few things that can slow down SSH logins."
echo "--"
sed -ie "s/#UseDNS no/UseDNS no/" ${TARGET_NFS_DIR}/etc/ssh/sshd_config
sed -ie "s/ mdns4_minimal \\[NOTFOUND=return\\]//" ${TARGET_NFS_DIR}/etc/nsswitch.conf
sed -ie "s/session\toptional\tpam_systemd.so//" ${TARGET_NFS_DIR}/etc/pam.d/common-session

echo "--"
echo "Install distcc, and setup distcc per default on all our netbooted clients."
echo "This can distribute and speed up the complation of EE by using the clients."
echo "--"
chroot ${TARGET_NFS_DIR} apt-get -y install distcc

sed -ie 's/STARTDISTCC="false"/STARTDISTCC="true"/' ${TARGET_NFS_DIR}/etc/default/distcc
sed -ie 's/ALLOWEDNETS="127.0.0.1"/ALLOWEDNETS="192.168.0.0\/16 172.16.0.0\/12 10.0.0.0\/8"/' ${TARGET_NFS_DIR}/etc/default/distcc
sed -ie 's/LISTENER="127.0.0.1"/LISTENER="0.0.0.0"/' ${TARGET_NFS_DIR}/etc/default/distcc
sed -ie "s/JOBS=\"\"/JOBS=\"2\"/" ${TARGET_NFS_DIR}/etc/default/distcc
sed -ie 's/ZEROCONF="false"/ZEROCONF="true"/' ${TARGET_NFS_DIR}/etc/default/distcc

echo "--"
echo "Create extra scripts to ease the maintenance of this machine:"
echo "dhcp_client.sh, dhcp_server.sh, and update.sh"
echo "--"
cat > /etc/network/interfaces.dhcp_client <<-EOT
auto lo
iface lo inet loopback

allow-hotplug ${ETH}
auto ${ETH}
iface ${ETH} inet dhcp
EOT

cat > /root/dhcp_client.sh <<-EOT
#!/bin/bash
## Script to stop the DHCP and TFTP servers and use the network interface as a normal client
##   interface that can access other networks.
systemctl stop dnsmasq
systemctl stop tftpd-hpa
ifdown -a
ifup -a -i /etc/network/interfaces.dhcp_client
EOT
chmod +x /root/dhcp_client.sh

cat > /root/dhcp_server.sh <<-EOT
#!/bin/bash
## Script to start the DHCP server and use the network interface to host the
##   network boot environment. Useful after switching the interface with dhcp_client.sh.
systemctl stop dnsmasq
systemctl stop tftpd-hpa
ifdown -a
ifup -a
ifup ${ETH}
systemctl start tftpd-hpa
systemctl start dnsmasq
EOT
chmod +x /root/dhcp_server.sh

cat > /root/update.sh <<-EOT
#!/bin/bash
## Script to update EE. This assumes this system can access the internet.
mount -t proc none ${TARGET_NFS_DIR}/proc
mount --bind /sys ${TARGET_NFS_DIR}/sys
mount --bind /dev ${TARGET_NFS_DIR}/dev
mount -t tmpfs none ${TARGET_NFS_DIR}/tmp

cp /etc/resolv.conf ${TARGET_NFS_DIR}/etc/resolv.conf
chroot ${TARGET_NFS_DIR} sh -c 'cd /root/SeriousProton/ && git pull'
chroot ${TARGET_NFS_DIR} sh -c 'cd /root/EmptyEpsilon/ && git pull'
chroot ${TARGET_NFS_DIR} sh -c 'cd /root/EmptyEpsilon/_build && cmake .. -G Ninja -DSERIOUS_PROTON_DIR=/root/SeriousProton/ && ninja'
EOT
chmod +x /root/update.sh
