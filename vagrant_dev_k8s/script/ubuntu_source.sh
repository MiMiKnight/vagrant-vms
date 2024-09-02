#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 设置软件源
# 优先推荐清华源，不推荐设置多软件源
##################################################
# 安装wget
sudo apt-get install -y wget
# 查看系统版本号（只能设置相应版本的软件源）
sudo lsb_release -a
#备份源
sudo cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
#变量
tsinghua_mirror='https://mirrors.tuna.tsinghua.edu.cn'
huawei_mirror='https://mirrors.huaweicloud.com'
aliyun_mirror='https://mirrors.aliyun.com'
######################清华源#######################
function tsinghua(){
sudo sed -i "s@http://.*archive.ubuntu.com@${tsinghua_mirror}@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@${tsinghua_mirror}@g" /etc/apt/sources.list
}
######################华为源#######################
function huawei(){
sudo sed -i "s@http://.*archive.ubuntu.com@${huawei_mirror}@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@${huawei_mirror}@g" /etc/apt/sources.list
}
######################阿里源#######################
function aliyun(){
sudo sed -i "s@http://.*archive.ubuntu.com@${aliyun_mirror}@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@${aliyun_mirror}@g" /etc/apt/sources.list
}
#############关闭upgrade自动升级内核#################
# 查看当前内核版本
sudo uname -r
# 查看目前存在的内核以及状态
# sudo dpkg --get-selections | grep -E ^linux-*
sudo dpkg --get-selections | grep -E "(^linux-image)|(^linux-headers)|(^linux-modules)"
# 禁止upgrade自动更新内核
sudo apt-mark hold `sudo dpkg --get-selections | grep -E "(^linux-image)|(^linux-headers)|(^linux-modules)" | awk '{print $1}'`
###################################################
# 切换软件源
tsinghua
# 刷新软件源仓库索引
sudo apt-get update
# 更新软件
# sudo apt-get -y upgrade
# 更新软件
sudo apt-get -y dist-upgrade