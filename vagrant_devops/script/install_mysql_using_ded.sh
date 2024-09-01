#!/bin/bash
# 显示指令及参数
set -ex
#
# Installing MySQL on Linux Using Debian Packages from Oracle
# 官方安装教程链接  https://dev.mysql.com/doc/refman/8.0/en/linux-installation-debian.html
# 切换root用户
sudo su - root
# 创建基本目录
sudo mkdir -p \
 /opt/backup
# 变量定义
# mysql版本
mysql_version='mysql-server_8.0.37'
# 24.04 url=https://cdn.mysql.com/archives/mysql-8.0/mysql-server_8.0.37-1ubuntu24.04_amd64.deb-bundle.tar
# mysql tar文件下载链接
mysql_tar_url='https://cdn.mysql.com/archives/mysql-8.0/mysql-server_8.0.37-1ubuntu22.04_amd64.deb-bundle.tar'
# mysql 压缩包名
mysql_tar_name='mysql-server_8.0.37-1ubuntu22.04_amd64.deb-bundle.tar'
# root密码
mysql_root_password='123456'
# 下载MySQL二进制安装包
sudo axel -n 8 -T 300 -k \
 -o /opt/backup/${mysql_tar_name} ${mysql_tar_url}
# 解压 mysql tar 压缩包
sudo mkdir -p /opt/backup/${mysql_version}
sudo tar -xvf /opt/backup/${mysql_tar_name} \
  --directory /opt/backup/${mysql_version}
#
sudo apt-get install apt-utils -y
# Preconfigure the MySQL server package with the following command:
sudo /usr/bin/expect << EOF
set timeout 60
spawn bash -c "sudo dpkg-preconfigure -f readline /opt/backup/${mysql_version}/mysql-community-server_*.deb"
expect "Enter root password:" { send "${mysql_root_password}\r" }
expect "Re-enter root password:" { send "${mysql_root_password}\r" }
expect "Select default authentication plugin" { send "1\r" }
expect eof
EOF
# 如果dpkg（如libmecab2）警告您未满足的依赖关系，您可以使用apt-get修复它们：
sudo apt-get -fy install
# 安装MySQL
sudo dpkg -i /opt/backup/${mysql_version}/mysql-{common,community-client-plugins,community-client-core,community-client,client,community-server-core,community-server,server}_*.deb
# 自启动文件位置 /usr/lib/systemd/system/mysql.service
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
expect "Enter password:" { send "${mysql_root_password}\r" }
expect "mysql>" { send "alter user 'root'@'localhost' identified by '${mysql_root_password}';\r" }
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
sudo rm -rf /opt/backup/${mysql_version}
sudo apt-get autoclean
# 切换vagrant用户
sudo su - vagrant
sudo echo "Install MySQL success!!!"
