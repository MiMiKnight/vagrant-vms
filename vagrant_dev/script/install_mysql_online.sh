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
# 切换root用户
sudo su - root
# 创建基本目录
sudo mkdir -p /opt/backup /opt/app
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
sudo wget --timeout=600 --tries=2 \
 -O /opt/backup/libaio1_0.3.113-5_amd64.deb \
 http://archive.ubuntu.com/ubuntu/pool/main/liba/libaio/libaio1_0.3.113-5_amd64.deb
sudo dpkg -i /opt/backup/libaio1_0.3.113-5_amd64.deb
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
#server-id=100
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/mysql.sock
log-error=/usr/local/mysql/data/mysql.err
secure_file_priv=/usr/local/mysql/mysql-files
local_infile=OFF
autocommit=1
EOF

sudo chown -R root:root /usr/local/mysql/my.cnf
sudo chmod 644 -R /usr/local/mysql/my.cnf
# 初始化数据文件夹
sudo mkdir -p /usr/local/mysql/data
sudo chown -R mysql:mysql /usr/local/mysql/data
sudo chmod 750 -R /usr/local/mysql/data
sudo /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --initialize
# 创建自启动文件
sudo cat > /usr/lib/systemd/system/mysqld.service << EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

# Have mysqld write its state to the systemd notify socket
Type=notify

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf $MYSQLD_OPTS 

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 10000

Restart=on-failure

RestartPreventExitStatus=1

# Set environment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

PrivateTmp=false
EOF

sudo chmod 644 /usr/lib/systemd/system/mysqld.service
# 开启开机自启动
systemctl enable mysqld.service
# 启动MySQL
systemctl start mysqld
# 查看MySQL状态
systemctl status mysqld
# 重置MySQL密码
sudo /usr/bin/expect << EOF
set timeout 60
spawn /usr/local/mysql/bin/mysql -u root -p
expect "Enter password:" { send "p\r" }
expect eof
EOF
# 切换vagrant用户
sudo su - vagrant
#
sudo echo "Install MySQL success!!!"
