#!/bin/bash
# Installing MySQL on Linux Using Debian Packages from Oracle
# 官方安装教程链接  https://dev.mysql.com/doc/refman/8.0/en/linux-installation-debian.html
# 显示指令及参数
sudo set -ex
# 切换root用户
sudo su - root
# 创建基本目录
sudo mkdir -p \
 /opt/backup
# 下载MySQL二进制安装包
sudo axel -n 8 -T 300 -k \
 -o /opt/backup/mysql-server_8.0.37-1ubuntu24.04_amd64.deb-bundle.tar \
 https://downloads.mysql.com/archives/get/p/23/file/mysql-server_8.0.37-1ubuntu24.04_amd64.deb-bundle.tar
# 解压 mysql tar 压缩包
sudo mkdir -p /opt/backup/mysql-8.0.37
sudo tar -xvf /opt/backup/mysql-server_8.0.37-1ubuntu24.04_amd64.deb-bundle.tar \
  --directory /opt/backup/mysql-8.0.37
#
sudo apt-get install apt-utils
# Preconfigure the MySQL server package with the following command:
sudo /usr/bin/expect << EOF
set timeout 60
spawn sudo dpkg-preconfigure -f readline /opt/backup/mysql-8.0.37/mysql-community-server_*.deb
expect "Enter root password:" { send "123456\r" }
expect "Re-enter root password:" { send "123456\r" }
expect "Select default authentication plugin" { send "1\r" }
expect eof
EOF
# 安装MySQL
sudo dpkg -i /opt/backup/mysql-8.0.37/mysql-{common,community-client-plugins,community-client-core,community-client,client,community-server-core,community-server,server}_*.deb
sudo apt-get -fy install
sudo dpkg -i /opt/backup/mysql-8.0.37/mysql-{common,community-client-plugins,community-client-core,community-client,client,community-server-core,community-server,server}_*.deb
# /usr/lib/systemd/system/mysql.service
# 开启开机自启动
sudo systemctl enable mysql.service
# 启动MySQL
sudo systemctl start mysql
# 查看MySQL状态
sudo systemctl status mysql
#
sudo /usr/bin/expect << EOF
set timeout 60
spawn mysql -u root -p
expect "Enter password:" { send "123456\r" }
expect "mysql>" { send "alter user 'root'@'localhost' identified by '123456';\r" }
expect "mysql>" { send "use mysql;\r" }
expect "mysql>" { send "select host,user from user;\r" }
expect "mysql>" { send "update user set host='%' where user='root';\r" }
expect "mysql>" { send "flush privileges;\r" }
expect "mysql>" { send "quit;\r" }
expect eof
EOF
#
sudo systemctl start mysql
# 清理
sudo rm -rf /opt/backup/mysql-8.0.37
sudo apt-get autoclean
# 切换vagrant用户
sudo su - vagrant
sudo echo "Install MySQL success!!!"
