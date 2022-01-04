---
title: 定制自己的Linux ISO镜像
description: 为已有的Linux ISO镜像添加自己的功能。
toc: false
authors: kushidou
tags: 
  - Linux学习与解决方案
categories: []
series: []
date: 2022-01-04T09:17:38+08:00
lastmod: 2022-01-04T09:17:38+08:00
featuredVideo:
featuredImage:
draft: false
---

想要在原版的Linux镜像上添加自定义的软件，但是不想、不会编译，那么就可以基于Linux的iso文件进行修改，定制自己的安装试用镜像。

<!--more-->

起因是因为对付信创操作系统的备份恢复时，UOS、麒麟自带的工具都超级不好用，两个系统的镜像不统一，导致实际使用的时候各种问题和不方便。所以使用clonezilla再生龙工具自己做一个PE镜像。这个镜像不仅可以备份、安装系统，还能够修改硬盘大小、应急拯救系统等多种功能。并且它是一个完整的系统可以安装使用。

## 基本计划

之前尝试过使用[deepin魔改lub工具](http://bbs.wuyou.net/forum.php?mod=viewthread&tid=409980)制作系统的完整镜像，但是启动总是失败。[LUB](https://forum.ubuntu.org.cn/viewtopic.php?t=206287)全称是*Live Ubuntu Backup*，是Ubuntu的一个工具，到了同为Debian系的deepin魔改的UOS上就水土不服了。（好绕，套娃呢搁这儿

所以采取另一种办法，用已有的Linux iso，通过解压其系统文件filesystem.squashfs，然后替换关键文件，最后实现自定义系统。

## 解压、修改、打包Linux文件系统

首先把Linux iso挂载到系统中。把里面的filesystem.squashfs文件复制出来（因为iso是只读的，复制出来后也方便管理和备份）。我这里以UOS1040为例，其文件系统在`./live`目录下

```bash
sudo mount -o loop /xxx/xxx.iso  /media/usrname/isofolder
cd /media/usrname/isofolder/live/
cp ./filesystem.squashfs ~
```

安装`squashfs-tools`工具，用来压缩解压归档文件。

```bash
sudo apt install squashfs-tools
#回到主目录后，解压filesystem.squashfs文件
sudo unsquashfs filesystem.squashfs
```

解压后可以看到主目录多一个`squashfs-root`目录，里面存放的就是一个Linux的文件系统了。这时候把你需要的文件拷贝进去，比如我替换了/usr、/opt、/etc三个目录，这三个目录保存了我安装的clonezilla应用及其配置程序，以及我编写的辅助脚本和自启动脚本。

修改好了就可以打包了。第一个参数是刚刚解压出来修改好的文件系统，第二个参数是输出的名称。建议把之前拷贝出来的squashfs文件改名进行保存。

```bash
sudo mksquashfs squashfs-root/ filesystem.squashfs
```

## 重建Linux iso

最后我们需要重建ISO文件。由于我们是基于原来的ISO修改的，所以只需要替换iso里面的filesystem.squashfs文件即可。否则还需要更换系统内核img/lz、重写引导。

把新生成的filesystem.squashfs文件拷贝到Windows系统里，打开UltraISO软件，直接替换Live目录下的filesystem.squashfs文件。同时我们也可以修改`EFI/grub.cfg`文件，毕竟这个系统主要是使用而不是安装。我调换了安装和试用的次序，并把等待时间增加到60s。

最后进行修改ISO名称等小操作，保存为ISO文件就可以了。

新生成的ISO文件既可以用rufus等工具烧录到U盘中制作PE盘，也可以试用ventoy工具制作成多系统启动盘，甚至可以烧录一张光盘来使用。

