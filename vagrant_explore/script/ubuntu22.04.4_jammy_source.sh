#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 设置软件源
# 适用系统版本：Ubuntu 22.04.4 LTS jammy
# 优先推荐清华源，不推荐设置多软件源
##################################################
# 安装wget
sudo apt-get install -y wget
# 查看系统版本号（只能设置相应版本的软件源）
sudo lsb_release -a
######################清华源#######################
sudo cat > /etc/apt/sources.list.d/tsinghua.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
EOF
######################华为源#######################
sudo cat > /etc/apt/sources.list.d/huawei.list << EOF
deb https://mirrors.huaweicloud.com/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ jammy-backports main restricted universe multiverse
EOF
######################阿里源#######################
sudo cat > /etc/apt/sources.list.d/aliyun.list << EOF
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
jammy-updates
deb https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
EOF
#############关闭upgrade自动升级内核#################
# 查看当前内核版本
sudo uname -r
# 查看目前存在的内核以及状态
# sudo dpkg --get-selections | grep -E ^linux-*
sudo dpkg --get-selections | grep -E "(^linux-image)|(^linux-headers)|(^linux-modules)"
# 禁止upgrade自动更新内核
sudo apt-mark hold `sudo dpkg --get-selections | grep -E "(^linux-image)|(^linux-headers)|(^linux-modules)" | awk '{print $1}'`
###################################################
# 删除华为源和阿里源 保留清华源
sudo rm -rf /etc/apt/sources.list.d/{huawei,aliyun}.list
# 刷新软件源仓库索引
sudo apt-get update
# 更新软件
# sudo apt-get -y upgrade
# 更新软件
sudo apt-get -y dist-upgrade