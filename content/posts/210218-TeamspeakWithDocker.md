---
title: 使用Docker安装TeamSpeak
description: install teamspeak with docker
toc: true
authors: Kushidou
tags: 
  - teamspeak
  - Linux
  - Tools
  - Docker
categories: []
series: []
date: 2021-02-18
lastmod: 2021-02-18
featuredVideo:
featuredImage: "https://cdn.jsdelivr.net/gh/kushidou/PicLibrary/img/image-20210526173013413.png"
draft: false
---

TeamSpeak的官网总是有些问题，无法下载其客户端，所以考虑使用Docker来部署一个ts服务器环境。

<!--more-->

## Teamspeak

TeamSpeak（简称ts）是一款实时语音聊天软件，是替换yy语音的一个很好的选择。ts唯一的缺点是其服务器在国外，不论下载客户端还是服务端都是一个很麻烦的事情，且下载服务端后需要诸多配置和环境依赖，如果哪天不用了卸载也是一个麻烦事儿。

所以，选择docker安装ts就是一个很不错的选择。

## Docker及其安装

docker是一个容器，可以打包一个程序及其依赖，然后移植到任意系统运行而不报错。

我的服务器的腾讯云轻量-Wordpress应用，没有自带docker，所以第一步先安装docker：

```shell
sudo yum install docker	#安装docker程序，会自动选择合适的
sudo systemctl start docker	#启动docker服务
sudo systemctl enable docker	#允许docker开机自启
```

## Docker安装TS

`docker run -dit -p 9987:9987/udp -p 10011:10011 -p 30033:30033 -e TS3SERVER_LICENSE=accept teamspeak`

直接运行这条指令，docker就会自动寻找下载ts的容器并启动。如果下载太慢则自行查找修改docker仓库源的方式。

## 端口

从指令可以看出，docker需要使用到**9987,10011,30033**三个端口，所以需要到服务器后台开启防火墙上对应端口。

## 管理员密钥

TS允许用户成为管理员，在首次运行的时候会在log中打印。不过docker运行时添加了-dit参数表示后台运行，所以查看参数需要额外的操作。

`docker ps -a`查找所有容器。

`docker logs -f [CONTATINER ID]`查看log，找到token即可。客户端设置之后再说。

密钥只会在第一次运行时打印，注意保存。


*参考：[https://woolio.cn/683/](https://woolio.cn/683/)*