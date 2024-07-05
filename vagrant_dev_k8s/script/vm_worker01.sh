#!/bin/bash
# 显示指令及参数
sudo set -ex
sudo hostnamectl hostname worker01.k8s.dev.vm.mimiknight.cn
sudo echo "Install K8S Worker01 VM finished !!!"