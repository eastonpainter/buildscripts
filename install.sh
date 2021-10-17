loadkeys colemak
timedatectl set-ntp true
cfdisk /dev/sdb
mkfs.ext4 -L BOOT /dev/sda1
mkfs.ext4 -L ROOT /dev/sda2
mkfs.ext4 -L HOME /dev/sda3
mkswap -L SWAP /dev/sda4
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda2 /mnt
mount /dev/sda3 /mnt/home
swapon /dev/sda4
basestrap /mnt base base-devel linux linux-firmware openrc elogind-openrc vim
fstabgen -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 10
artix-chroot /mnt
zsh
vim /etc/pacman.d/mirrorlist
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc
touch /etc/locale.gen && echo "en_US.UTF-8 UTF-8\nen_US ISO-8859-1" > /etc/locale.gen
locale-gen
touch /etc/locale.conf && echo "LANG=en_US.UTF-8" > /etc/locale.conf
touch /etc/vconsole.conf && echo "KEYMAP=colemak" > /etc/vconsole.conf
touch /etc/hostname && echo "ironhide" > /etc/hostname
touch /etc/hosts && cat ~/.build/hosts > /etc/hosts
vim /etc/hosts
touch /etc/conf.d/hostname && echo "hostname='ironhide'" > /etc/conf.d/hostname
passwd
pacman -S dhcpcd networkmanager grub
# possibly networkmanager
rc-update add NetworkManager
# grub-install --recheck /dev/sdb
grub-install --target=i386-pc /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg
doas useradd -m -g wheel evelyn
passwd evelyn
pacman -S --needed - < ~/.build/pkgs.txt
exit
lsblk 
sleep 5
umount -R /mnt
reboot
