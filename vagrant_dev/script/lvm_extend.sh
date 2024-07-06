#!/bin/bash
# 显示指令及参数
sudo set -ex
##################################################
# LVM 自动扩容
##################################################
# 扩容大小
capacity=$1
[ ! $1 ] && capacity='+100G'
# 安装自动交互工具expect
# sudo apt-get install -y tcl expect
# LVM自动扩容
sudo /usr/bin/expect << EOF
set timeout 60
spawn parted -l
expect "Fix/Ignore?" { send "Fix\r" }

spawn gdisk /dev/sdb
expect "Command (? for help):" { send "p\r" }
expect "Command (? for help):" { send "n\r" }
expect "Partition number*:" { send "1\r" }
expect "First sector*:" { send "\r" }
expect "Last sector*:" { send "$capacity\r" }
expect "Hex code or GUID*:" { send "8e00\r" }
expect "Command (? for help):" { send "p\r" }
expect "Command (? for help):" { send "w\r" }
expect "Do you want to proceed? (Y/N):" { send "Y\r" }
expect eof
EOF
# 刷新分区表
sudo partprobe
# 查看磁盘分区
sudo lsblk
# 创建PV
sudo pvcreate /dev/sdb1
# VG扩容
sudo vgextend vg-root /dev/sdb1
# LV扩容
sudo lvextend -l +100%FREE /dev/vg-root/lv-root
# 刷新逻辑卷
sudo resize2fs /dev/vg-root/lv-root
# 查看挂载点扩容情况
sudo df -Th
#
sudo echo "LVM extend /dev/vg-root/lv-root success!!!"


