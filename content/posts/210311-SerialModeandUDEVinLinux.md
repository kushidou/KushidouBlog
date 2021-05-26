---
title: Linux串口和udev理解
description:
toc: false
authors: kushidou
tags: 
  - Linux
  - 串口
categories: []
series: Linux学习与解决方案
date: 2021-03-11
lastmod: 2021-03-11
featuredVideo:
featuredImage:
draft: false
---

配置串口权限，顺便看一下linux的udev规则。

<!--more-->

## 串口的问题

在现场开发的同事反映UOS工控机没有配置串口，每次都需要sudo才能使用。（明明在家里你们都会自己配置好环境与权限，为什么到了现场反而不会了需要我提供协助呢？）

我之前没考虑过这个问题，认为串口就是得root权限操作才安全。但是既然提出了需求，就赶紧百度并测试一下吧。

## 赋予普通用户串口权限的两种方法

在百度上，给普通用户串口权限有两种主流方法（可能2会了，Google上不去），一种是将用户放入特殊的用户组，从而获得权限。另一种是加入udev规则，在串口插入时自动更改权限。

我个人更倾向于使用第二种方案，因为公司中不同的人装系统就可能起不同的名字，之后进入生产环境可能又会起新的名字，所以采用第二种设置规则的办法，便于之后制作恢复镜像和一键部署。

## xxx.rules

`sudo vi /etc/udev/rules.d/70-tty-usb-rules`，写入以下内容：

```shell
KERNEL=="ttyS*",MODE="0666"
KERNEL=="ttyUSB*",MODE="0666"
```

这一段的意思是匹配所有ttyS和ttyUSB，插入时都赋予0666的权限，即所有用户都可读可写。重新加载一下设备，就可以按规则配置权限进行操作了。

## udev规则

udev是什么？udev是Linux下的设备文件管理方式，运行在用户侧（devfs在内核侧管理设备文件）。有了udev，`/dev`目录下的文件就都是真实存在的已连接的设备了。

udev的规则都保存在`/etc/udev/rules.d`目录下，文件名的格式为`数字-名称.rules`，数字表示加载顺序，一般是从小往大加载；名称按功能自定义，最后以.rules结尾。这些规则会在设备接入时生效。

规则文件按行执行，每行分为两个部分：匹配和赋值，每个参数使用逗号,分割。

> （这段复制自引用2，仅供参考）。
> **1、udev 规则的所有操作符**
> **==**　　比较键、值，若等于，则该条件满足；
> **!=** 　比较键、值，若不等于，则该条件满足；
> **=** 　 对一个键赋值；
> **+=**　　为一个表示多个条目的键赋值。
> **:=**　　对一个键赋值，并拒绝之后所有对该键的改动，防止后面的规则文件对该键重赋值。
>
> **2、udev 规则的匹配键**
> **ACTION** 　 　　　　　事件 (uevent) 的行为，例如：add、remove。
> **KERNEL** 　 　　　　　　内核设备名称，例如：sda, cdrom。
> **DEVPATH**　　　　　　　  设备的 devpath 路径。
> **SUBSYSTEM** 　　　　　 设备的子系统名称，例如：sda 的子系统为 block。
> **BUS** 　　　　　　　　　 设备在 devpath 里的总线名称，例如：usb。
> **DRIVER** 　　　 　　　 设备在 devpath 里的设备驱动名称，例如：ide-cdrom。
> **ID** 　　　　　　　 　　　设备在 devpath 里的识别号。
> **SYSFS{filename}** 　　　设备的 devpath 路径下，设备的属性文件“filename”里的内容。
> **ENV{key}** 　　　　　  环境变量。在一条规则中，可以设定最多五条环境变量的 匹配键。
> **PROGRAM**　　　　　　　　调用外部命令。
> **RESULT** 　　　　　　　  外部命令 PROGRAM 的返回结果。
>
> **3、udev 的重要赋值键** 
> **NAME**　　　　　　　　　　　/dev目录下显示的文件名重命名
> **SYMLINK**　　　　　　　　　 为 /dev下文件进行符号链接，防止覆盖系统默认产生的文件
> **OWNER, GROUP, MODE**　　为设备设定权限。
> **ENV{key}**　　　　　　　　　导入一个环境变量。
>
> **4、udev 的值和可调用的替换操作符** 
> Linux 用户可以随意地定制 udev 规则文件的值。例如：my_root_disk, my_printer。同时也可以引用下面的替换操作符：
> **$kernel, %k**　　　　　　　　设备的内核设备名称，例如：sda、cdrom。
> **$number, %n**　　　　　　　 设备的内核号码，例如：sda3 的内核号码是 3。
> **$devpath, %p**　　　　　　　设备的 devpath路径。
> **$id, %b**　　　　　　　　　　设备在 devpath里的 ID 号。
> **$sysfs{file}, %s{file}**　　  设备的 sysfs里 file 的内容。其实就是设备的属性值。
> **$env{key}, %E{key}**　　　一个环境变量的值。
> **$major, %M**　　　　　　　　设备的 major 号。
> **$minor %m**　　　　　　　　设备的 minor 号。
> **$result, %c**　　　　　　　　PROGRAM 返回的结果。
> **$parent, %P**　　　　　　   父设备的设备文件名。
> **$root, %r**　　　　　　　　  udev_root的值，默认是 /dev/。
> **$tempnode, %N**　　　　　　临时设备名。
> **%%**　　　　　　　　　　　　符号 % 本身。
> **\$\$**　　　　　　　　　　　　　符号 $ 本身。



## 参考
[1]https://www.cnblogs.com/qixianyu/p/6869744.html
[2]https://www.cnblogs.com/cslunatic/p/3171837.html

