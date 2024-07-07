#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 安装harbor（前提：安装docker以及docker-compose）
# 安装harbor前置条件 https://goharbor.io/docs/2.9.0/install-config/installation-prereqs/
##################################################
# 切换root用户
sudo su - root
# CA域名
ca_domain=$1
[ ! $1 ] && ca_domain='ca.mimiknight.cn'
# 应用域名
app_domain=$2
[ ! $2 ] && app_domain='harbor.devops.vm.mimiknight.cn'
# CA的cert密码
ca_cert_passwd=$3
[ ! $3 ] && ca_cert_passwd='4nkrQQHntJ5clOzcivoLNBzsv'
# 应用的cert密码
app_cert_passwd=$4
[ ! $4 ] && app_cert_passwd='Y01JDA8rBodvfS84Qe1Z639Z2'
# 创建基本目录
sudo mkdir -p \
/opt/backup \
/opt/app/cert/ca \
/opt/app/cert/harbor \
/opt/app/data/harbor \
/etc/docker/certs.d/${app_domain}
# 下载harbor
sudo axel -n 12 -T 300 -k \
 -o /opt/backup/harbor-offline-installer-v2.11.0.tgz \
 https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-offline-installer-v2.11.0.tgz
# 安装OpenSSL
sudo apt-get install -y openssl
# 生成CA私钥（私钥aes256加密）
####################生成自签名CA证书#####################
sudo openssl genrsa \
-aes256 \
-passout pass:${ca_cert_passwd} \
-out /opt/app/ca/${ca_domain}.pem 4096
# 生成CA CSR文件
sudo openssl req -new \
 -subj "/C=CN/ST=JiangSu/L=NanJing/O=MiMiKnight/OU=MiMiKnight/CN=${ca_domain}" \
 -key /opt/app/cert/ca/${ca_domain}.pem \
 -passin pass:${ca_cert_passwd} \
 -out /opt/app/cert/ca/${ca_domain}.csr
# 生成CA私钥自签名证书文件（10年有效期）
sudo openssl x509 -req -days 3650 \
 -in /opt/app/cert/ca/${ca_domain}.csr \
 -signkey /opt/app/cert/ca/${ca_domain}.pem \
 -passin pass:${ca_cert_passwd} \
 -out /opt/app/cert/ca/${ca_domain}.crt
# 把PEM格式的CA证书转化成DER格式的CA证书
sudo openssl x509 \
 -in /opt/app/cert/ca/${ca_domain}.crt \
 -inform PEM \
 -out /opt/app/cert/ca/${ca_domain}.der \
 -outform DER
################生成CA签名的应用证书#################
# 生成应用CA私钥（私钥aes256加密）
sudo openssl genrsa \
-aes256 \
-passout pass:${app_cert_passwd} \
-out /opt/app/cert/harbor/${app_domain}.pem 4096
# 生成应用 CSR文件
sudo openssl req -new \
 -subj "/C=CN/ST=JiangSu/L=NanJing/O=MiMiKnight/OU=MiMiKnight/CN=${app_domain}" \
 -key /opt/app/cert/harbor/${app_domain}.pem \
 -passin pass:${app_cert_passwd} \
 -out /opt/app/cert/harbor/${app_domain}.csr
# 私有CA生成应用证书（10年有效期,pass:CA密码）
sudo openssl x509 -req -days 3650 \
 -in /opt/app/cert/harbor/${app_domain}.csr \
 -CA /opt/app/cert/ca/${ca_domain}.crt \
 -CAkey /opt/app/cert/harbor/${ca_domain}.pem \
 -passin pass:${ca_cert_passwd} \
 -CAcreateserial \
 -out /opt/app/cert/harbor/${app_domain}.crt
# 校验应用的crt证书是否由ca的crt签发(# OK表示校验通过)
sudo openssl verify -CAfile \
 /opt/app/cert/ca/${app_domain}.crt \
 /opt/app/cert/harbor/${app_domain}.crt
# 生成无密码的应用证书私钥（加密私钥生成无密私钥，pass：应用证书密码）
sudo openssl rsa \
 -in /opt/app/cert/harbor/${app_domain}.pem \
 -passin pass:${app_cert_passwd} \
 -out /opt/app/cert/harbor/${app_domain}.nopass.pem
###################配置harbor######################
# 解压
sudo tar -xvf /opt/backup/harbor-offline-installer-v2.11.0.tgz \
  --directory /opt/app
# 解压位置：/opt/backup/harbor
# 复制重命名harbor.yml.tmpl文件
sudo cp /opt/app/harbor/harbor.yml.tmpl \
 /opt/app/harbor/harbor.yml
# 修改域名
sudo sed -i 's/hostname: reg.mydomain.com/hostname: ${app_domain}/g' /opt/app/harbor/harbor.yml
sudo awk '/^hostname: /{print $0}' /opt/app/harbor/harbor.yml
# 修改证书位置
sudo sed -i 's#/your/certificate/path#/opt/app/cert/harbor/${app_domain}.crt#g' /opt/app/harbor/harbor.yml
sudo awk '/^  certificate: /{print $0}' /opt/app/harbor/harbor.yml
# 修改证书密钥位置
sudo sed -i 's#/your/private/key/path#/opt/app/cert/harbor/${app_domain}.nopass.pem#g' /opt/app/harbor/harbor.yml
sudo awk '/^  private_key: /{print $0}' /opt/app/harbor/harbor.yml
# 修改数据位置
sudo sed -i 's#data_volume: /data#data_volume: /opt/app/data/harbor#g' /opt/app/harbor/harbor.yml
sudo awk '/^data_volume: /{print $0}' /opt/app/harbor/harbor.yml
###################安装harbor######################
# 编译/安装
cd /opt/app/harbor
#sudo ./prepare
sudo ./install.sh
cd ~
# 查看
sudo docker images
sudo docker ps -a
sudo docker ps
####################客户端访问#####################
# 客户端安装
# /opt/app/ca/ca.mimiknight.cn.crt 
# 访问
# https://yourdomain
##################################################
# 切换vagrant用户
sudo su - vagrant
#
sudo echo "Install harbor success!!!"