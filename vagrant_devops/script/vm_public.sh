#!/bin/bash
# 显示指令及参数
sudo set -ex
# 安装wget
sudo apt-get install -y wget
# 备份软件源
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
# 设置指定的软件源
sudo sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list.d/ubuntu.sources
# 更新软件源
sudo apt-get update
# 更新更新已经安装的软件并解决相关依赖问题
sudo apt-get dist-upgrade -y
# 安装系统基础软件
sudo apt-get install -y \
  vim iputils-ping net-tools lrzsz gcc \
  ntp ntpdate gdisk parted telnet tcl expect axel
# 设置NTP服务器
sudo ntpdate ntp.vm.mimiknight.cn
#sudo ntpdate ntp.aliyun.com
# 删除系统中不再需要的软件包及其依赖项
sudo apt-get autoremove
# 清理已经安装的软件包
sudo apt-get autoclean
# 输出提示
sudo echo "Run public shell script finished !!!"