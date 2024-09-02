#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 公共脚本
##################################################
####################Ubuntu设置DNS####################
# 变量
DNS='10.101.0.254 223.5.5.5 223.6.6.6'
function dns(){
sudo cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
sudo sed -i "s/#DNS=/DNS=${DNS}/g" /etc/systemd/resolved.conf
sudo awk '/^DNS=/{print $0}' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
sudo systemctl enable systemd-resolved
}
dns
######################基础设置#######################
function base(){
# 安装系统基础软件
sudo apt-get install -y \
  dialog vim iputils-ping lrzsz tcl expect \
  ntpdate gdisk parted telnet axel dos2unix apt-utils
# 设置NTP服务器
sudo ntpdate ntp.vm.mimiknight.cn
#sudo ntpdate ntp.aliyun.com
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai
# 查看本地时间
sudo date
# 删除系统中不再需要的软件包及其依赖项
#sudo apt-get autoremove
# 清理已经安装的软件包
sudo apt-get autoclean
}
base
######################禁用swap#######################
function forbid_swap(){
# 查看是否swap分区
sudo swapon --show
# 临时禁用swap分区
sudo swapoff -a
# 永久禁用swap分区
sed -i '8s/^/# /g' /etc/fstab
# 查看是否swap分区
sudo swapon --show
sudo free -h
}
forbid_swap
###############允许root用户SSH登陆###################
ssh_port='22'
function allow_root_ssh(){
sudo sed -i "s/#Port 22/Port ${ssh_port}/g" /etc/ssh/sshd_config
sudo awk '/^Port ${ssh_port}/{print $0}' /etc/ssh/sshd_config
sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo awk '/^PasswordAuthentication/{print $0}' /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sudo awk '/^PermitRootLogin/{print $0}' /etc/ssh/sshd_config
# 重启SSH
sudo service sshd restart
}
allow_root_ssh
####################################################
# 输出提示
sudo echo "Run public shell script finished !!!"