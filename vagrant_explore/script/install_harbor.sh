#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 安装harbor（前提：安装docker以及docker-compose）
# 安装harbor前置条件 https://goharbor.io/docs/2.9.0/install-config/installation-prereqs/
##################################################
# 切换root用户
sudo su - root
# 创建基本目录
mkdir -p \
/opt/backup \
/opt/app/ca \
/opt/app/harbor\
/opt/app/harbor/ssl
# 下载harbor
sudo axel -n 12 -T 300 -k \
 -o /opt/backup/harbor-offline-installer-v2.11.0.tgz \
 https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-offline-installer-v2.11.0.tgz
# 安装OpenSSL
sudo apt-get install -y openssl
# 生成CA私钥（私钥aes256加密）
####################生成自签名CA证书#####################
openssl genrsa \
-aes256 \
-passout pass:4nkrQQHntJ5clOzcivoLNBzsv \
-out /opt/app/ca/ca.mimiknight.cn.pem 4096
# 生成CA CSR文件
openssl req -new \
 -subj "/C=CN/ST=JiangSu/L=NanJing/O=MiMiKnight/OU=MiMiKnight/CN=ca.mimiknight.cn" \
 -key ca.mimiknight.cn.pem \
 -passin pass:4nkrQQHntJ5clOzcivoLNBzsv \
 -out /opt/app/ca/ca.mimiknight.cn.csr
# 生成CA私钥自签名证书文件（10年有效期）
openssl x509 -req -days 3650 \
 -in ca.mimiknight.cn.csr \
 -signkey ca.mimiknight.cn.pem \
 -passin pass:4nkrQQHntJ5clOzcivoLNBzsv \
 -out /opt/app/ca/ca.mimiknight.cn.crt
# 把PEM格式的CA证书转化成DER格式的CA证书
openssl x509 \
 -in /opt/app/ca/ca.mimiknight.cn.crt \
 -inform PEM \
 -out /opt/app/ca/ca.mimiknight.cn.der \
 -outform DER
################生成CA签名的应用证书#################
# 生成应用CA私钥（私钥aes256加密）
openssl genrsa \
-aes256 \
-passout pass:Y01JDA8rBodvfS84Qe1Z639Z2 \
-out /opt/app/harbor/ssl/harbor.mimiknight.cn.pem 4096
# 生成应用 CSR文件
openssl req -new \
 -subj "/C=CN/ST=JiangSu/L=NanJing/O=MiMiKnight/OU=MiMiKnight/CN=harbor.devops.vm.mimiknight.cn" \
 -key /opt/app/harbor/ssl/harbor.mimiknight.cn.pem \
 -passin pass:Y01JDA8rBodvfS84Qe1Z639Z2 \
 -out /opt/app/harbor/ssl/harbor.mimiknight.cn.csr
# 私有CA生成应用证书（10年有效期）
openssl x509 -req -days 3650 \
 -in harbor.mimiknight.cn.csr \
 -CA /opt/app/ca/ca.mimiknight.cn.crt \
 -CAkey /opt/app/ca/ca.mimiknight.cn.pem \
 -passin pass:4nkrQQHntJ5clOzcivoLNBzsv \
 -CAcreateserial \
 -out /opt/app/harbor/ssl/harbor.mimiknight.cn.crt
# 校验harbor.mimiknight.cn.crt证书是否由ca.mimiknight.cn.crt签发(# OK表示校验通过)
openssl verify -CAfile \
 /opt/app/ca/ca.mimiknight.cn.crt \
 /opt/app/harbor/ssl/harbor.mimiknight.cn.crt
# 生成无密码私钥（加密私钥生成无密私钥）
openssl rsa \
 -in /opt/app/harbor/ssl/harbor.mimiknight.cn.pem \
 -passin pass:4nkrQQHntJ5clOzcivoLNBzsv \
 -out /opt/app/harbor/ssl/harbor.mimiknight.cn.nopass.pem
###################配置harbor######################
# 解压
sudo tar -xvf /opt/backup/harbor-offline-installer-v2.11.0.tgz \
  --directory /opt/backup/harbor
# 解压位置：/opt/backup/harbor/harbor
# 重命名
sudo mv /opt/backup/harbor/harbor /opt/backup/harbor/harbor-2.11.0
# 复制重命名harbor.yml.tmpl文件
sudo cp /opt/backup/harbor/harbor-2.11.0/harbor.yml.tmpl \
 /opt/backup/harbor/harbor-2.11.0/harbor.yml
# 修改域名
sed -i 's/hostname: reg.mydomain.com/hostname: harbor.devops.vm.mimiknight.cn/g' /opt/backup/harbor/harbor-2.11.0/harbor.yml
awk '/^hostname: /{print $0}' /opt/backup/harbor/harbor-2.11.0/harbor.yml
# 修改证书位置
sed -i 's/  certificate: /your/certificate/path/  certificate: /opt/app/harbor/ssl/harbor.mimiknight.cn.crt/g' /opt/backup/harbor/harbor-2.11.0/harbor.yml
awk '/^  certificate: /{print $0}' /opt/backup/harbor/harbor-2.11.0/harbor.yml
# 修改证书密钥位置
sed -i 's/  private_key: /your/private/key/path/  private_key: /opt/app/harbor/ssl/harbor.mimiknight.cn.nopass.pem/g' /opt/backup/harbor/harbor-2.11.0/harbor.yml
awk '/^  private_key: /{print $0}' /opt/backup/harbor/harbor-2.11.0/harbor.yml
###################安装harbor######################
# 编译/安装
sudo bash /opt/backup/harbor/harbor-2.11.0/prepare
sudo bash /opt/backup/harbor/harbor-2.11.0/install.sh
# 查看
sudo docker images
sudo docker ps -a
sudo docker ps
####################客户端访问#####################
# 客户端安装
# /opt/app/ca/ca.mimiknight.cn.crt 
# 访问
# https://harbor.devops.vm.mimiknight.cn
##################################################
# 切换vagrant用户
sudo su - vagrant
#
sudo echo "Install harbor success!!!"