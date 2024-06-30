#!/bin/bash
# 安装MySQL
# 官方安装教程链接  https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/secure-deployment-install.html
# 显示指令及参数
sudo set -ex
# 错误退出函数
error_exit (){
  echo "ERROR: $1 !!"
  exit 1
}
# 切换root用户
sudo su - root
# 创建基本目录
sudo mkdir -p \
 /opt/backup \
 /opt/app/mysql \
 /opt/workspace/mysql/data
# 创建mysql用户
sudo groupadd -g 500 -o -r mysql
sudo useradd -M -N -g mysql -o -r -d /home/mysql -s /usr/sbin/nologin -c "MySQL Server" -u 500 mysql
# 查看是否新增用户成功
awk '/mysql/{print $0}' /etc/passwd
# 修改目录用户属性
chown -R mysql:mysql /opt/app/mysql /opt/workspace/mysql
chmod -R 750 /opt/app/mysql /opt/workspace/mysql
### 查看GLIBC版本
ldd --version
# 下载MySQL二进制安装包
sudo wget --timeout=600 --tries=2 \
 -O /opt/backup/mysql-8.0.37-linux-glibc2.28-x86_64.tar \
 https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.37-linux-glibc2.28-x86_64.tar
 # 安装 libaio library
sudo apt-cache search libaio
sudo apt-get install -y libaio-dev
sudo apt-get install -y libaio1t64
sudo apt-get install -y libncurses6
sudo wget --timeout=600 --tries=2 \
 -O /opt/backup/libaio1_0.3.113-5_amd64.deb \
 http://archive.ubuntu.com/ubuntu/pool/main/liba/libaio/libaio1_0.3.113-5_amd64.deb
sudo dpkg -i /opt/backup/libaio1_0.3.113-5_amd64.deb
# 解压 mysql tar 压缩包
sudo mkdir -p /opt/backup/mysql-8.0.37
sudo tar xf /opt/backup/mysql-8.0.37-linux-glibc2.28-x86_64.tar \
  --directory /opt/backup/mysql-8.0.37
# 解压安装 mysql tar.xz 压缩包
sudo tar xf /opt/backup/mysql-8.0.37/mysql-8.0.37-linux-glibc2.28-x86_64.tar.xz \
  --directory /opt/app/mysql
# 修改目录用户属性
chown -R mysql:mysql /opt/app/mysql
chown -R mysql:mysql /opt/workspace/mysql
# 建立软链接
sudo ln -s /opt/app/mysql/mysql-8.0.37-linux-glibc2.28-x86_64 /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
ln -s /opt/workspace/mysql/data /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/data
# 设置MySQL环境变量
sudo cat > /etc/profile.d/mysql.sh << EOF
export MYSQL_HOME=/usr/local/mysql
export PATH=\$MYSQL_HOME/bin:\$MYSQL_HOME/support-files:\$PATH
EOF
# 环境变量生效
source /etc/profile
# 验证
mysql -V
# 创建MySQL配置文件
sudo cat > /opt/workspace/mysql/my.cnf << EOF
############################[client]###############################
[client]
# 客户端连接默认端口号
port=3306
# 客户端连接时字符集默认编码
default-character-set=utf8mb4
# 指定socket
#socket=/usr/local/mysql/mysql.sock
############################[mysql]###############################
[mysql]
# 开启命令自动补齐给你
no-auto-rehash
# 字符集默认编码
default-character-set=utf8mb4
[client]
#port=3306
############################[mysqld]###############################
[mysqld]
# 数据库唯一标识,主从必用且唯一
server-id=100
# 安装目录
basedir=/usr/local/mysql
# 数据位置
datadir=/usr/local/mysql/data
# 指定socket
#socket=/usr/local/mysql/mysql.sock
# 指定PID文件
#pid-file=/usr/local/mysql/mysqld.pid
# 指定缓存目录
#tmpdir=
# 以什么用户运行
user=mysql
# 服务端端口号
port=3306
# 允许连接数据库的主机地址
bind_address=0.0.0.0
# 服务端字符集默认编码
character-set-server=utf8mb4
# 数据库默认时区
default-time-zone='+00:00'
# 默认存储引擎类型
default-storage-engine=INNODB
# 开启自动提交
autocommit=1
# 错误日志
log-error=/usr/local/mysql/data/mysql.err
# 开启慢查询日志
slow-query-log=on
# 慢查询日志路径
#slow-query-log-file=
# 慢查询的执行用时上限,默认设置是10s,推荐(1s~2s)
long-query-time=2
# 记录没有使用索引查询语句
log-queries-not-using-indexes=0
##########################[mysqldump]##############################
[mysqldump]
#设定在网络传输中一次消息传输量的最大值。系统默认值为1MB，最大值是1GB，必须设置为1024的倍数。单位为字节。
max-allowed-packet=2M
##########################[mysqld_safe]############################
[mysqld_safe]
open-files-limit=8192
EOF
# 创建配置文件软连接
ln -s /opt/workspace/mysql/my.cnf /usr/local/mysql/my.cnf

# 初始化数据（默认root密码为空）
sudo /usr/local/mysql/bin/mysqld \
 --user=mysql \
 --basedir=/usr/local/mysql \
 --datadir=/usr/local/mysql/data \
 --initialize-insecure
# 修改目录或者文件权限
chown -R mysql:mysql /opt/app/mysql
chown -R mysql:mysql /opt/workspace/mysql
chown root:root /opt/workspace/mysql/my.cnf
chmod 644 /opt/workspace/mysql/my.cnf
# 不允许删除my.cnf
chattr +i /opt/workspace/mysql/my.cnf
lsattr /opt/workspace/mysql/my.cnf
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
# 设置自启动配置文件权限
sudo chmod 644 /usr/lib/systemd/system/mysqld.service
# 开启开机自启动
sudo systemctl enable mysqld.service
# 启动MySQL
sudo systemctl start mysqld
# 查看MySQL状态
sudo systemctl status mysqld
sudo /usr/bin/expect << EOF
set timeout 60
spawn /usr/local/mysql/bin/mysql -u root -p
expect "Enter password:" { send "\r" }
expect "mysql>" { send "alter user 'root'@'localhost' identified by '123456';\r" }
expect "mysql>" { send "use mysql;\r" }
expect "mysql>" { send "select host,user from user;\r" }
expect "mysql>" { send "update user set host='%' where user='root';\r" }
expect "mysql>" { send "flush privileges;\r" }
expect "mysql>" { send "quit;\r" }
expect eof
EOF
# 重启MySQL
sudo systemctl restart mysqld
# 查看MySQL状态
sudo systemctl status mysqld
# 清理
sudo rm -rf /opt/backup/mysql-8.0.37
sudo apt-get autoclean
# 切换vagrant用户
sudo su - vagrant
sudo echo "Install MySQL success!!!"
