#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 设置软件源
# 适用系统版本：Ubuntu 24.04 LTS noble
# 优先推荐清华源，不推荐设置多软件源
##################################################
# 安装wget
sudo apt-get install -y wget
# 查看系统版本号（只能设置相应版本的软件源）
sudo lsb_release -a
######################清华源#######################
sudo cat > /etc/apt/sources.list.d/tsinghua.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-proposed main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
EOF
######################华为源#######################
sudo cat > /etc/apt/sources.list.d/huawei.list << EOF
deb https://mirrors.huaweicloud.com/ubuntu/ noble main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ noble main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ noble-security main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ noble-security main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ noble-updates main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ noble-proposed main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ noble-proposed main restricted universe multiverse

deb https://mirrors.huaweicloud.com/ubuntu/ noble-backports main restricted universe multiverse
deb-src https://mirrors.huaweicloud.com/ubuntu/ noble-backports main restricted universe multiverse
EOF
######################阿里源#######################
sudo cat > /etc/apt/sources.list.d/aliyun.list << EOF
deb https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-proposed main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
EOF
###################################################
# 删除清华源和阿里源 保留华为源
sudo rm -rf /etc/apt/sources.list.d/{tsinghua,aliyun}.list
# 刷新软件源仓库索引
sudo apt-get update
# 更新软件(不升级内核)
sudo apt-get -y upgrade
# 更新软件(会升级内核，须谨慎)
# sudo apt-get -y dist-upgrade