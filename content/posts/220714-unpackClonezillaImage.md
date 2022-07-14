---
title: 从再生龙（clonezilla）镜像直接提取文件
description:
toc: false
authors: kushidou
tags: 
  - clonezilla
  - Linux
categories: []
series: [Linux学习与解决方案]
date: 2022-07-14T13:05:51+08:00
lastmod: 2022-07-14T13:05:51+08:00
featuredVideo:
featuredImage:
draft: false
---

从clonezilla的镜像直接提取文件，免于先全盘全区恢复。

<!--more-->

再生龙（clonezilla）是一个常用的Linux系统备份工具，适用于多个版本、多种CPU架构的电脑。

再生龙生成的镜像是比较特殊的格式，如果想要从里面提取文件，通常只能进行镜像恢复后进入系统提取。但是往往我们没有那么多硬盘来恢复系统。

再生龙的原理简单来说就是把硬盘分区使用partclone工具打包成img文件，然后使用gzip进行分卷压缩。我们只需要逆向操作，利用工具，把镜像解包挂载，直接在当前系统挂载，就可以得到原分区的文件了。

## 挂载方法：

### 1. 环境需求

我们操作再生龙镜像时，最好是使用Linux环境。这个环境中，需要安装partclone（也就是再生龙生成镜像的核心工具）。

```bash
sudo apt install partclone
# 以Debian系为例
```

并且我们需要准备一个足够大的硬盘，用来存储镜像包和解包出的img文件。硬盘/分区的空间需要大于镜像本来的**分区**空间。

### 2. 合并镜像

再生龙默认情况下会把一个硬盘分区分按4GB的大小进行分包，通常以`gz.aa`、`gz.ab`等结尾，我们需要把这些包重新整合成一个gz包。

整合成gz包后，我们就可以解压gz来得到镜像img了。我们可以把两个步骤用流的方式写入一条命令，节省硬盘空间。

```bash
cat sda1.ext4-ptcl-img.gz.* | gzip -d -c > sda1.img
```

这一步生成的img文件不能直接使用（google上也有说能用的，但是我试下来不能），需要进行一次转换。经过实际操作，这个文件所占用的空间是镜像原分区的大小，但是统计硬盘使用量时却只计算实际大小，希望了解的人可以帮忙解释一下。

```bash
partclone.extfs -r -s sda1.img -o sda1-ex.img --restore_raw_file
```

当然上面两条指令也可以使用流的方式再次封装到一条，但是消耗的时间、失败后重新来过的时间，都会更长。

## 3.挂载镜像

将最后生成的img镜像挂载到我们的/mnt（或其他）目录，进入这个目录就可以看到原来全部的文件了。

```bash
sudo mount -o loop -t ext4 sda1-ex.img /mnt
```

最后我们只需要进入 `/mnt` 目录，就可以想直接操作硬盘一样把文件复制出来了。



