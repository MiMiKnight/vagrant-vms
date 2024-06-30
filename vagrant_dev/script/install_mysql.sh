#!/bin/bash
# 安装MySQL
# 官方安装教程链接  https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/secure-deployment-install.html
# 以root用户身份执行以下脚本
set -ex
# 错误退出函数
error_exit (){
  echo "ERROR: $1 !!"
  exit 1
}
# 创建基本目录
sudo mkdir -p /opt/backup /opt/app
sudo cd /opt/backup
sudo wget --timeout=600 --tries=2 \
 -O /opt/backup/mysql-8.0.29-linux-glibc2.12-x86_64.tar \
 https://mirrors.huaweicloud.com/mysql/Downloads/MySQL-8.0/mysql-8.0.29-linux-glibc2.12-x86_64.tar
# 下载md5校验文件
sudo wget --timeout=600 --tries=2 \
 -O /opt/backup/mysql-8.0.29-linux-glibc2.12-x86_64.tar.md5 \
 https://mirrors.huaweicloud.com/mysql/Downloads/MySQL-8.0/mysql-8.0.29-linux-glibc2.12-x86_64.tar.md5
 # 安装 libaio library
sudo apt-cache search libaio
sudo apt-get install -y libaio-dev
sudo apt-get install -y libaio1t64
# 校验
sudo md5sum -c mysql-8.0.29-linux-glibc2.12-x86_64.tar.md5
# 解压 mysql-8.0.29-linux-glibc2.12-x86_64.tar
sudo mkdir -p /opt/backup/mysql8.0.29
sudo tar xf /opt/backup/mysql-8.0.29-linux-glibc2.12-x86_64.tar \
  --directory /opt/backup/mysql8.0.29
# 解压安装 mysql-8.0.29-linux-glibc2.12-x86_64.tar.xz
sudo tar xf /opt/backup/mysql8.0.29/mysql-8.0.29-linux-glibc2.12-x86_64.tar.xz \
  --directory /opt/app
sudo ln -s /opt/app/mysql-8.0.29-linux-glibc2.12-x86_64 /usr/local/mysql
# 设置MySQL环境变量
sudo export PATH=/usr/local/mysql/bin:$PATH
# 创建mysql用户
sudo groupadd -g 500 -o -r mysql
sudo useradd -M -N -g mysql -o -r -d /home/mysql -s /usr/sbin/nologin -c "MySQL Server" -u 500 mysql
# 为导入和导出操作创建安全目录
sudo mkdir -p /usr/local/mysql/mysql-files
sudo chown -R mysql:mysql /usr/local/mysql/mysql-files
sudo chmod 750 -R /usr/local/mysql/mysql-files
# 创建MySQL配置文件
sudo cat > /usr/local/mysql/my.cnf << EOF
[mysql]
default-character-set=utf8mb4
[client]
#port=3306
[mysqld]
user=mysql
port=3306
#server-id=3306
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/mysql.sock
log-error=/usr/local/mysql/data/mysql.dev.vm.mimiknight.cn.err
secure_file_priv=/usr/local/mysql/mysql-files
local_infile=OFF
autocommit=1
EOF
#
sudo echo "Install MySQL success!!!"
