#!/bin/bash
# 显示指令及参数
set -ex
##################################################
# 安装Docker
##################################################
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新软件源
sudo apt-get -y update
# 安装指定版本的Docker-CE:
# Step 5: 查找Docker-CE的版本:
sudo apt-cache madison docker-ce
sudo apt-cache madison docker-ce-cli
sudo apt-cache madison docker-ce | awk 'NR == 1'  | awk {'print $3'}
# Step 6: 安装指定版本的Docker-CE: (VERSION例如上面的27.0.3-1~ubuntu.24.04~noble)
sudo apt-get -y install docker-ce=`sudo apt-cache madison docker-ce | awk 'NR == 1'  | awk {'print $3'}`
# 验证
sudo docker version
# 查看docker状态
sudo systemctl status docker
# 配置docker加速镜像地址
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://nj15n6e8.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl status docker
# 仅Python 3及以上版本支持docker-compose，并请确保已安装pip。
sudo apt-get install -y python3-pip
sudo pip3 -V
# 安装docker-compose v2.28.0
sudo curl -L https://github.com/docker/compose/releases/download/v2.28.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose version
#
sudo echo "Install docker success!!!"