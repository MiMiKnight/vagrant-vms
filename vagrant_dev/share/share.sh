#!/bin/bash
# 显示指令及参数
set -ex
################下载mariadb####################
mariadb_tar_url='https://mirrors.neusoft.edu.cn/mariadb//mariadb-11.4.3/bintar-linux-systemd-x86_64/mariadb-11.4.3-linux-systemd-x86_64.tar.gz'
mariadb_tar_name='mariadb-11.4.3-linux-systemd-x86_64.tar.gz'
wget -c ${mariadb_tar_url} \
 -o ./${mariadb_tar_name}
#############下载docker-compos#################
# https://github.com/docker/compose/releases/download/v2.28.0/docker-compose-`uname -s`-`uname -m`
docker_compose_url='https://github.com/docker/compose/releases/download/v2.28.0/docker-compose-Linux-x86_64'
docker_compose_name='docker-compose'
wget -c ${docker_compose_url} \
 -o ./${docker_compose_name}