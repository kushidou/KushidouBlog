---
title: DEB打包方法简介
description: Debian系Linux，如ubuntu, deepin等系统的deb打包教程
toc: true
authors: kushidou
tags: 
  - Linux
  - Deepin/UOS
categories: []
series: Linux学习与解决方案
date: 2021-10-19T10:12:23+08:00
lastmod: 2021-10-19T10:12:23+08:00
featuredVideo:
featuredImage:
draft: false
---

简单介绍deb打包的方法，包括目录树格式和打包注意事项。

<!--more-->

## 文件结构

首先创建一个目录作为工作空间，目录名可以使用软件名，deb包所有文件都将会存在这个目录下，这个目录就是安装时的根目录`/`。一个工作空间的目录树如下：

```
  PackageDIR
	├─DEBIAN
    ├─opt
    │  └─kushidou-touchscreen
    │      └─desktops
    ├─usr
    │  ├─bin
    │  └─share
    └─var
```

其中，`DEBIAN`目录放置了安装包的信息、配置、控制文件等，其他文件都放在目录的相对位置里，安装时就会根据这些相对位置，把程序与文件直接拷贝到对应的地方。

## DEBIAN

`DEBIAN`目录下有一个control文件和至多四个脚本文件。

### control

`control`文件用于写入安装包的识别信息，包括包名、版本、作者、简介等。没有严格的顺序要求。表格中列出常用的关键字和作用，图片展示了一个软件包的control信息。control文件最后需要添加一个空行。

| NAME         | Description                                 |
| ------------ | ------------------------------------------- |
| Package      | 软件名，`dpkg -l` 列出的名字                |
| Version      | 版本号-修订号                               |
| Section      | 软件类型，比如mail, test, x11等             |
| Priority     | 优先级/重要性，比如optional  可选的         |
| Architecture | 软件架构，比如x86, arm64                    |
| Depends      | 依赖环境，用 `,` 隔开，用`(>=< )`指定版本号 |
| Suggests     | 推荐安装，指非必要依赖，可以提供更多功能    |
| Maintainer   | 作者  <邮箱或者其他联系方式>                |
| Descritprion | 简介，可以换行书写                          |

![image-20211019094048011](https://cdn.jsdelivr.net/gh/kushidou/PicLibrary/img/20211019101901.png)

### 额外脚本

`DEBIAN`目录下之多放置四个可执行脚本，包括**安装前`preinst`**、**安装后`postinst`**、**卸载前`prerm`**、**卸载前`postrm`**，四个脚本都需要以`#!/bin/bash`开头，内容与普通脚本无异，文件名不需要后缀。

这些脚本主要实现复制快捷方式、建立软连接、添加环境变量、添加额外的文件和配置等操作。这些脚本是以`root`身份运行，注意他们创建文件的访问权限。inst创建的文件无法被dpkg删除，需要使用rm脚本自行处理。

此外`postinst`可以用来启动已安装的程序，`prerm`常用来停止正在运行的程序。

### md5sums

为了防止安装包被篡改，可以计算每个二进制文件的md5值存放在这个文件里。非必要。

## 打包

所有文件配置完成后，进入工作空间上级目录，执行指令

```bash
dpkg -b ./PackageDIR packagename.deb
```

deb包命名的一般规则为 **软件名\_版本-修订号_架构.deb**

## 其他信息

一般公开发行的安装包应该包含其他信息，如版权信息、changelog、doc、man手册等。这些文件都有各自的编撰格式，主要是为了方便系统识别和二次开发，与用户直接体验无关。