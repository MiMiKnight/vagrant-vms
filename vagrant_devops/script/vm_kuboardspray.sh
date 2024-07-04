#!/bin/bash
# 安装教程 https://kuboard-spray.cn/
# Kuboard-Spray 的默认用户名是 admin，默认密码是 Kuboard123
# 显示指令及参数
sudo set -ex
#
sudo mkdir -p \
 /opt/workspace/data/kuboard-spray
#
sudo docker pull swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard-spray:v1.2.4-amd64
#
sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --name=kuboard-spray \
  -p 80:80/tcp \
  -e TZ=Asia/Shanghai \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/workspace/data/kuboard-spray:/data \
  swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard-spray:v1.2.4-amd64
#
sudo echo "Install KuboardSpray VM finished !!!"