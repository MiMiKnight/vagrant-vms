#!/bin/bash
# 显示指令及参数
sudo set -ex
##########################安装harbor##########################
# 创建基本目录
sudo mkdir -p \
 /opt/backup
# 安装openssl
sudo apt-get install -y openssl
# 生成证书

# 下载安装包
sudo axel -n 8 -T 300 -k \
 -o /opt/backup/harbor-offline-installer-v2.10.3.tgz \
 https://github.com/goharbor/harbor/releases/download/v2.10.3/harbor-offline-installer-v2.10.3.tgz
# 解压
sudo tar -xvf /opt/backup/harbor-offline-installer-v2.10.3.tgz \
  --directory /opt/backup
# /opt/backup/harbor
##############################################################
sudo echo "Install Harbor finished !!!"