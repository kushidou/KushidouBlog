---
title: 讨论在Debian系操作系统中重新提取已安装的软件并重新打包
description: 
toc: true
authors: kushidou
tags: 
  - linux
  - deepin
categories: []
series: [linux学习与解决方案]
date: 2023-05-08T14:43:41+08:00
lastmod: 2023-05-08T14:43:41+08:00
featuredVideo:
featuredImage:
draft: false
---

Debian系操作系统采用dpkg作为包管理器，在安装软件后会存储deb包信息，是否可以提取这些信息并且重新打deb包转移到其他平台使用？

<!--more-->

之前有一个需求，要从UOS里面提取一个软件，并且将其安装到另一台设备中。当时找了一圈都没有找到相关的提取教程。但是从逻辑上来讲，dpkg安装的软件会保存deb包的相关信息，所以理论上讲是可以提取出软件包的所有内容，然后我们重新打包的。

今天在一个机缘巧合下（其实是懒得研究dpkg原理，瞎猫撞上死耗子），发现了dpkg保存文件信息的地点，于是接下来可以展开畅想：提取已经安装的软件并重新打包。

## 文件的保存地点

我在找fcitx有关的配置文件进行全盘搜索的时候，找到了一条目录`/usr/lib/dpkg-db/info`，这个目录里面保留了fcitx的"conffiles", "md5sums", "postinst", "prerm"四个文件，以及一个list文件。恰好fcitx.deb解包出来的DEBIAN文件夹内也是这四个文件加上额外的control文件，。

那么合理猜测，dpkg安装软件的时候，不仅把软件本身的文件移动到对应位置，还把DEBIAN里面的信息和脚本也转移到`/usr/lib/dpkg-db/`里面保存了。

而`fcitx.list`文件中记录的是所有的文件及其路径。想必这里面就是全部的文件了。

至于control文件，则都被保存到了`/usr/lib/dpkg-db/status`这个文本文件中。

## 流程设想

既然deb包所有必要的文件都找到了，那么就可以尝试一下还原过程了。在[这篇文章](https://www.small09.top/posts/211019-dpkg_package_guide/)里我研究过deb包的组成、格式和打包方法。

比如对于软件包A：

1. 创建一个工作目录，并在其中新建`DEBIAN`目录。

2. 将`/usr/lib/dpkg-db/info`中所有该软件的脚本和信息(除了A.list)转移到`DEBIAN`中，并重命名成规范名称。

3. 将`/usr/lib/dpkg-db/status`中与软件A有关的部分提取出来，保存到`DEBIAN/control`文件中。

4. 根据A.list文件，找到软件包含的所有文件，将其按原样整理到工作目录内。

5. 使用`dpkg -b`指令重新打包。

## 局限性

以上毕竟只是设想，没有进行试验，所以估计会出现这些问题，希望有需要的人尝试后可以解决。

- 提取信息的难度： 由于`/usr/lib/dpkg-db/status`文件是一个包含几乎所有deb信息的文本文件，体积大内容乱，对于自动化脚本来说有些难度。加上一些软件的衍生品会在软件名上直接加后缀，对于提取的脚本来讲可能造成混淆，提取出不必要的东西。

- 获取源文件的难度： 不排除一些软件安装时会删除、修改自身的一些文件，可能打包会后会缺失内容。一些软件安装过程中会进行手动配置从而造成内容改变，重做出来的软件包不一定完整。

- 签名问题： 我们打包的软件没有原作者的数字签名，可能无法安装，也可能时候安装官方软件时冲突。

- 这个方案只能处理普通的软件，一些deb打包源码，安装时进行编译的，应该是不能用这种方案复原的。（apt的deb-src源）

最后，希望有大佬可以验证一下这个方案。