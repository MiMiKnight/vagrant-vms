#!/bin/bash
# 显示指令及参数
sudo set -ex
# 安装harbor（前提：安装docker以及docker-compose）
# 安装harbor前置条件 https://goharbor.io/docs/2.9.0/install-config/installation-prereqs/
# 切换root用户
sudo su - root
# 创建基本目录
sudo mkdir -p \
 /opt/backup
# 下载harbor
sudo axel -n 12 -T 300 -k \
 -o /opt/backup/harbor-offline-installer-v2.11.0.tgz \
 https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-offline-installer-v2.11.0.tgz
# 新建证书存储目录
mkdir -p /opt/backup/rsa-secret
#
sudo echo "Install harbor success!!!"