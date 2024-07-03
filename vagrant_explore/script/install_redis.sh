#!/bin/bash
# 官网教程链接 https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/
# 显示指令及参数
sudo set -ex
# 安装Redis
#
sudo apt install lsb-release curl gpg
sudo curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
# 更新软件源
sudo apt-get update
# 查看redis全部可用版本
sudo apt-cache madison redis 
# 查看本次安装的redis版本
sudo apt-cache madison redis | awk 'NR == 1'  | awk {'print $3'}
# 安装指定版本的redis
# sudo apt-get install -y redis=6:7.2.5-1rl1~noble1
sudo apt-get install -y redis=`sudo apt-cache madison redis | awk 'NR == 1'  | awk {'print $3'}`
# 查看redis版本
sudo redis-server --version
#
sudo echo "Install docker success!!!"