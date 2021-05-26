---
title: Linux启用四个以上的串口
description:
toc: false
authors: kushidou
tags: 
  - Linux
  - 串口
categories: []
series: Linux学习与解决方案
date: 2021-04-20
lastmod: 2021-04-20
featuredVideo:
featuredImage:
draft: false
---

工控板安装Linux常常最多只能看到四个串口，通过修改引导文件可以显示所有的串口。

<!--more-->

## 先说结论

```shell
# 1.修改开机grub文件
sudo vi /etc/default/grub
# 2.在"GRUB_CMDLINE_LINUX_DEFAULT="一行的结尾空格，添加内容
 8250.nr_uarts=8
# 3.更新开机引导并重启
sudo update-grub
```

## 再说细节

给带有多串口的工控机安装国产Linux操作系统UOS，发现`/dev/ttyS`只有四个，而且一个都不通，其实这是Linux 的通病，如果发行商没有提前配置，我们只能看到四个不能用的串口。但是工控机都有8-16个串口，不得不想办法让他们能够正常使用，而许多串口芯片只需要基本的驱动就能运行，也不提供专有驱动的源代码编译<font size=2 color=#ff0000>（一般安装专用驱动后，串口名称会改变，比如xr17v358芯片的驱动安装后名称变成ttyXR0）</font>，我们只有从linux本身下手了。

经过多番查找资料，虽然不知道为什么，但是我们应该修改`/etc/default/grub`文件，其中有一行是这样的：

```shell
GRUB_CMDLINE_LINUX_DEFAULT="这里面 的内容 先不管 它"
```

我看了UOS（含Deepin）、Ubuntu和服务器的Centos7都有，在这一行的最后添加`8250.nr_uart=32`，其中数字<=32都行，效果如下：

```shell
GRUB_CMDLINE_LINUX_DEFAULT="这里面 的内容 先不管 它 8250.nr_uarts=32"
```

然后更新一下系统的引导

```shell
sudo update-gurb
reboot
```

重启完了你就能看到更多的串口啦！配合[修改udev规则](https://www.small09.top/?p=24)，你就可以用普通用户的权限使用串口通信了。但是请注意其他隐患，比如这个芯片配合基本驱动只能完成基础的收发功能，流控的RTS、CTS等还是需要专用驱动实现的！

## 最后吐槽

为了串口问题我找了一下午的资料，最后才在外网找到了一个能用的。国内的教程都是说要修改`/boot/gurb/gurb2`，宝友，这可不兴改啊，这个改坏了系统可就没了啊！这些文件普通用户连浏览权限都没就可见其重要性。

## 参考：

https://blog.wjacobsen.dk/2019/05/03/enable-more-than-4-serial-ports-linux-unix/

核心步骤就参考了这个，在Linux方面大家还是多用google，多用英文去搜索吧！

