#!/bin/bash
# 显示指令及参数
set -ex
#
# 安装MariaDB
# 官方安装教程链接 https://mariadb.org/wp-content/uploads/2024/08/MariaDBServerKnowledgeBase.pdf
# 切换root用户
sudo su - root
# 变量
mariadb_tar_url='https://mirrors.neusoft.edu.cn/mariadb//mariadb-11.4.3/bintar-linux-systemd-x86_64/mariadb-11.4.3-linux-systemd-x86_64.tar.gz'
mariadb_tar_name='mariadb-11.4.3-linux-systemd-x86_64.tar.gz'
mariadb_install_dir_name='mariadb-11.4.3-linux-systemd-x86_64'
mariadb_version='mariadb-11.4.3'
root_password='123456'
# 创建基本目录
sudo mkdir -p \
 /opt/backup \
 /opt/app/mariadb \
 /opt/workspace/mariadb/data
# 创建mysql用户
sudo groupadd -g 500 -o -r mysql
sudo useradd -M -N -g mysql -o -r -d /home/mysql -s /usr/sbin/nologin -c "MySQL Server" -u 500 mysql
# 查看是否新增用户成功
sudo awk '/mysql/{print $0}' /etc/passwd
# 修改目录用户属性
sudo chown -R mysql:mysql /opt/app/mariadb /opt/workspace/mariadb
sudo chmod -R 750 /opt/app/mariadb /opt/workspace/mariadb
### 查看GLIBC版本
ldd --version
# 下载MySQL二进制安装包
function download(){
sudo axel -n 12 -T 600 -k \
 -o /opt/backup/${mariadb_tar_name} ${mariadb_tar_url}
}
download
#sudo cp /opt/share/${mariadb_tar_name} /opt/backup/${mariadb_tar_name}
# 安装 libaio library
sudo apt-cache search libaio
sudo apt-get install -y libaio-dev
#sudo apt-get install -y libaio1t64
sudo apt-get install -y libncurses*
sudo apt-get install -y libncurses5
# 解压安装 mysql tar.xz 压缩包
sudo tar xf /opt/backup/${mariadb_tar_name} \
  --directory /opt/app/mariadb
sudo mv /opt/app/mariadb/${mariadb_install_dir_name} /opt/app/mariadb/${mariadb_version}

# 修改目录用户属性
sudo chown -R mysql:mysql /opt/app/mariadb
sudo chown -R mysql:mysql /opt/workspace/mariadb
# 建立软链接
sudo ln -s /opt/app/mariadb/${mariadb_version} /usr/local/mysql
sudo chown -R mysql:mysql /usr/local/mysql
sudo ln -s /opt/workspace/mariadb/data /usr/local/mysql/data
sudo chown -R mysql:mysql /usr/local/mysql/data
# 设置MySQL环境变量
sudo cat > /etc/profile.d/mariadb.sh << EOF
export MARIADB_HOME=/usr/local/mysql
export PATH=\$MARIADB_HOME/bin:\$MARIADB_HOME/support-files:\$PATH
EOF
# 环境变量生效
source /etc/profile
# 验证
mariadb -V
# 创建MySQL配置文件
sudo cat > /opt/workspace/mariadb/my.cnf << EOF
############################[client]###############################
[client]
# 客户端连接默认端口号
port=3306
# 客户端连接时字符集默认编码
default-character-set=utf8mb4
# 插件位置
#plugin-dir=
# 指定socket
#socket=
############################[mysql]###############################
[mysql]
# 开启命令自动补齐给你
no-auto-rehash
# 字符集默认编码
default-character-set=utf8mb4
############################[mysqld]###############################
[mysqld]
# 数据库唯一标识,主从必用且唯一
server-id=100
# 安装目录
basedir=/usr/local/mysql
# 数据位置
datadir=/usr/local/mysql/data
# 指定socket
#socket=
# 指定PID文件
#pid-file=
# 指定缓存目录
#tmpdir=
# 以什么用户运行
user=mysql
# 服务端端口号
port=3306
# 允许连接数据库的主机地址
#bind-address=127.0.0.1
bind-address=0.0.0.0
# 服务端字符集默认编码
character-set-server=utf8mb4
# 数据库默认时区
default-time-zone='+00:00'
# 默认存储引擎类型
default-storage-engine=INNODB
# 错误日志
#log-error=
# 表示同时访问 MySQL 服务器的最大连接数
max-connections=100
# #设置每个主机的连接请求异常中断的最大次数，当超过该次数，MySQL服务器将禁止host的连接请求，直到MySQL服务器重启或通过flush hosts命令清空此host的相关信息。
max-connect-errors=20
# 指定一个请求的最大连接时间，对于4GB左右内存的服务器来说，可以将其设置为5~10
wait-timeout=120
# 开启慢查询日志
slow-query-log=on
# 慢查询日志路径
#slow-query-log-file=
# 慢查询的执行用时上限,默认设置是10s,推荐(1s~2s)
long-query-time=2
# 记录没有使用索引查询语句
log-queries-not-using-indexes=0
# 禁用DNS查询
skip-name-resolve
# 禁止缓存主机名
skip-host-cache
############################[mysqldump]###############################
[mysqldump]
#设定在网络传输中一次消息传输量的最大值。系统默认值为1MB，最大值是1GB，必须设置为1024的倍数。单位为字节。
max-allowed-packet=2M
############################[mysqld_safe]###############################
#以safe方式启动数据库，相比于mysqld,会在服务启动后继续监控服务状态，死机时重启
[mysqld_safe]
open-files-limit=8192
EOF
# 创建配置文件软连接
ln -s /opt/workspace/mariadb/my.cnf /usr/local/mysql/my.cnf

# 初始化数据（默认root密码为空）
sudo /usr/local/mysql/scripts/mariadb-install-db \
 --user=mysql \
 --basedir=/usr/local/mysql \
 --datadir=/usr/local/mysql/data
# 修改目录或者文件权限
chown -R mysql:mysql /opt/app/mariadb
chown -R mysql:mysql /opt/workspace/mariadb
chown root:root /opt/workspace/mariadb/my.cnf
chmod 644 /opt/workspace/mariadb/my.cnf
# 不允许删除my.cnf
#chattr +i /opt/workspace/mariadb/my.cnf
lsattr /opt/workspace/mariadb/my.cnf
# 创建自启动文件
sudo cat > /usr/lib/systemd/system/mariadb.service << EOF
[Unit]
Description=MariaDB Server
Documentation=man:mariadbd(8)
Documentation=https://mariadb.com/kb/en/library/systemd/
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
# 设置自启动配置文件权限
sudo chmod 644 /usr/lib/systemd/system/mariadb.service
# 开启开机自启动
sudo systemctl enable mariadb.service
# 启动MySQL
sudo systemctl start mariadb
# 查看MySQL状态
sudo systemctl status mariadb
#
sudo /usr/bin/expect << EOF
set timeout 60
spawn /usr/local/mysql/bin/mariadb -u root -p
expect "Enter password:" { send "\r" }
expect "MariaDB" { send "show databases;\r" }
expect "MariaDB" { send "use mysql;\r" }
expect "MariaDB" { send "show tables;\r" }
expect "MariaDB" { send "alter user 'root'@'localhost' identified by '123456';\r" }
expect "MariaDB" { send "select host,user from user;\r" }
expect "MariaDB" { send "grant all privileges on *.* to root@'%' identified by '123456' with grant option;\r" }
expect "MariaDB" { send "flush privileges;\r" }
expect "MariaDB" { send "quit;\r" }
expect eof
EOF
# 重启MySQL
sudo systemctl restart mariadb
# 查看MySQL状态
sudo systemctl status mariadb
# 清理
sudo apt-get autoclean
# 切换vagrant用户
sudo su - vagrant
sudo echo "Install mariadb success!!!"