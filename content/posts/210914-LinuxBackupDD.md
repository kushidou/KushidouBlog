---
title: 使用dd指令备份和恢复Linux系统（硬盘级）
description: Backup Linux with dd command.
toc: true
authors: kushidou
tags: 
  - Linux
  - Deepin/UOS
categories: []
series: Linux学习与解决方案
date: 2021-09-14T13:51:16+08:00
lastmod: 2021-09-14T13:51:16+08:00
featuredVideo:
featuredImage:
draft: false
---

害，谁不是个DD (誰でも 大好き)了呢!

<!--more-->

## 起因

使用UOS的时候经常需要备份镜像并分享给其他部门或者办事处的人。传统的方法是进入系统自带的Recovery分区，打开备份软件制作镜像，但是这存在两个问题：A. 镜像特别巨大，系统多大镜像就占多大。B. 必须先拥有系统，才能恢复镜像。最新版的系统中已经去掉了Recovery分区，而LiveCD镜像还不是很好用，于是有了这篇博客，试图寻找一个简单的方法来进行恢复和备份。

## DD说明

dd指令是一个简单的复制指令，它不管源和目标的编码、格式、数据结构，简单粗暴的把二进制数据从A复制到B。所以恢复的目标硬盘甚至不需要提前分区，因为dd会把分区信息也写入。

dd指令依然是有多少数据占多少空间，所以我们可以使用gzip进行压缩。具体代码后面贴出来。

实际使用中，发现dd指令除了方便，就没有其他优点了。它因为要读取硬盘所有数据（包括垃圾数据），即便用SSD，读盘速度还是会很慢，三刻钟才读了200GiB数据，平均75MB/s，而使用uos自带的deepin-clone，三个系统都备份完了。

## DD备份

```bash
dd if=/dev/sda of=/dev/sdb				=>    备份整个磁盘到另外一个磁盘
dd if=/dev/sdb of=sda.img				=>    备份整个磁盘为某个文件
dd if=/dev/sda | gzip > sda.img    		=>    备份并且压缩
dd if=/dev/sda bs=1M | gzip > sda.img	=>    指定块大小，备份并压缩（据说能提速）
```

## DD复原

```bash
dd if=/dev/sdb of=/dev/sda					=>从另一个磁盘恢复回来
gzip -dc sda.img | dd of=/dev/sda			=>从压缩的文件恢复出来
gzip -dc sda.img | dd of=/dev/sda bs=1M		=>前面指定了块大小，这里也需要
```

## 参考：

本文参考（抄）了以下内容：

[Linux 下使用 dd 和 gzip 命令来代替 Ghost 做磁盘镜像](http://vpsxyz.com/archives/87)

[linux dd实现磁盘完整全盘镜像备份backup,恢复recover(restore)](https://blog.csdn.net/weixin_33971130/article/details/85662628)

还有一些查找过程中作用不大的页面，就不贴出来了（诶嘿(╹ڡ╹ )