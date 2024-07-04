#!/bin/bash
# 显示指令及参数
sudo set -ex
#
mkdir -p \
 /opt/workspace/data/kuboard-spray
#
docker pull swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard-spray:v1.2.4-amd64
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