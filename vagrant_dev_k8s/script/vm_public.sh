#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 公共脚本
##################################################

######################基础设置#######################
# 安装系统基础软件
sudo apt-get install -y \
  vim iputils-ping net-tools lrzsz gcc \
  ntp ntpdate gdisk parted telnet tcl expect
# 设置NTP服务器
sudo ntpdate ntp.vm.mimiknight.cn
#sudo ntpdate ntp.aliyun.com
# 删除系统中不再需要的软件包及其依赖项
sudo apt-get autoremove
# 清理已经安装的软件包
sudo apt-get autoclean
######################禁用swap#######################
# 查看是否swap分区
sudo swapon --show
# 临时禁用swap分区
sudo swapoff -a
# 永久禁用swap分区
sed -i '8s/^/# /g' /etc/fstab
# 查看是否swap分区
sudo swapon --show
sudo free -h
###############允许root用户SSH登陆###################
sudo sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
sudo awk '/^Port 22/{print $0}' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo awk '/^PasswordAuthentication/{print $0}' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo awk '/^PermitRootLogin/{print $0}' /etc/ssh/sshd_config
# 重启SSH
sudo service sshd restart
####################################################
# 输出提示
sudo echo "Run public shell script finished !!!"