#!/bin/bash
# 显示指令及参数
set -ex
# 安装教程 https://kuboard-spray.cn/
# Kuboard-Spray 的默认用户名是 admin，默认密码是 Kuboard123
# 访问链接：http://kuboardspray.devops.vm.mimiknight.cn/#/login
#          https://kuboard.cn/v4/install/quickstart.html
# 切换用户
sudo su - root
# 创建数据目录
sudo mkdir -p \
 /opt/app/kuboard \
 /opt/workspace/data/kuboard-spray \
 /opt/workspace/data/kuboard-mariadb-data
# 拉取镜像
sudo docker pull swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard-spray:v1.2.4-amd64
sudo docker pull swr.cn-east-2.myhuaweicloud.com/kuboard/mariadb:11.3.2-jammy
sudo docker pull swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v4
#
sudo cat > /opt/app/kuboard/kuboard-v4.yaml << EOF
########################################
# kuboard docker-compose
# 参考：https://www.cnblogs.com/crazymakercircle/p/15505199.html
########################################
configs:
  create_db_sql:
    content: |
      CREATE DATABASE kuboard DEFAULT CHARACTER SET = 'utf8mb4' DEFAULT COLLATE = 'utf8mb4_unicode_ci';
      create user 'kuboard'@'%' identified by 'kuboardpwd';
      grant all privileges on kuboard.* to 'kuboard'@'%';
      FLUSH PRIVILEGES;
networks:
  kuboard_v4_dev:
    driver: bridge
services:
  db:
    restart: unless-stopped
    image: swr.cn-east-2.myhuaweicloud.com/kuboard/mariadb:11.3.2-jammy
    container_name: mariadb
    ports:
     - "3306:3306"
    environment:
      MARIADB_ROOT_PASSWORD: kuboardpwd
      MYSQL_ROOT_PASSWORD: kuboardpwd
      TZ: Asia/Shanghai
    volumes:
      - /opt/workspace/data/kuboard-mariadb-data:/var/lib/mysql:Z
    configs:
      - source: create_db_sql
        target: /docker-entrypoint-initdb.d/create_db.sql
        mode: 0777
    networks:
      kuboard_v4_dev:
        aliases:
          - db
  kuboard-spray:
    restart: unless-stopped
    image: swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard-spray:v1.2.4-amd64
    container_name: kuboard-spray
    privileged: true
    ports:
     - "8443:80"
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 1024M
    environment:
      TZ: Asia/Shanghai
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/workspace/data/kuboard-spray:/data
    networks:
      kuboard_v4_dev:
        aliases:
          - kuboard-spray
  kuboard:
    image: swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v4
    container_name: kuboard
    environment:
      - DB_DRIVER=org.mariadb.jdbc.Driver
      - DB_URL=jdbc:mariadb://db:3306/kuboard?serverTimezone=Asia/Shanghai
      - DB_USERNAME=kuboard
      - DB_PASSWORD=kuboardpwd
    ports:
      - '8444:80'
    depends_on:
      - db
    networks:
      kuboard_v4_dev:
        aliases:
          - kuboard
EOF
# 启动容器
sudo docker-compose -f /opt/app/kuboard/kuboard-v4.yaml up -d
# 切换用户
sudo su - vagrant
#
sudo echo "Install Kuboard finished !!!"