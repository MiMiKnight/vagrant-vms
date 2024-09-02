#!/bin/bash
# 显示指令及参数
set -ex
# 官网教程链接 https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/
# 安装Redis
# 变量
redis_password=123456
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
# 查看是否新增用户成功
awk '/redis/{print $0}' /etc/passwd
# 配置文件位置 /etc/redis/redis.conf
# 修改密码
sed -i "s/# requirepass foobared/requirepass ${redis_password}/g" /etc/redis/redis.conf
awk '/^requirepass /{print $0}' /etc/redis/redis.conf
# 修改ip
sed -i "s/bind 127.0.0.1 -::1/bind 0.0.0.0/g" /etc/redis/redis.conf
awk '/^bind 0.0.0.0/{print $0}' /etc/redis/redis.conf
# 自启动配置文件 /usr/lib/systemd/system/redis-server.service
# 重载配置文件
systemctl daemon-reload
# 设置自启动
systemctl enable redis-server.service
# 查看自启动状态
systemctl is-enabled redis-server.service
# 关闭服务
systemctl stop redis-server.service
#  启动服务
systemctl start redis-server.service
# 查看服务启动状态
systemctl status redis-server.service
#
sudo echo "Install redis success!!!"