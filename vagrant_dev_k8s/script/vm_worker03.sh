#!/bin/bash
# 显示指令及参数
sudo set -ex
sudo hostnamectl hostname worker03.k8s.dev.vm.mimiknight.cn
sudo echo "Install K8S Worker03 VM finished !!!"