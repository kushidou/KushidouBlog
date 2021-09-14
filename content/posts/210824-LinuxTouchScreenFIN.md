---
title: Linux处理多触屏的终极解决方案
description: Linux with mutli touch screen
toc: true
authors: kushidou
tags: 
  - Linux
  - Deepin/UOS
  - 触摸屏
categories: []
series: Linux学习与解决方案
date: 2021-08-24
lastmod: 2021-09-14
featuredVideo:
featuredImage:
draft: false
---

一般Linux操作系统接入多个触摸屏的最终解！

<!--more-->

从[21年3月中旬开始](https://www.small09.top/posts/210311-multitouchscreeninlinux/)，我就在不断探索Linux操作系统下接入多个触摸屏且为拓展显示的解决方案，随着我们遇到的问题不断变得复杂，那篇博客也越来越乱越来越难读。直到今天我把里面最复杂的方案尝试成功后，我感觉我已经获得了Linux触摸屏的终极奥义。

*重要：* 本文全文基于软件`xinput`

*更重要：* 如简介所说，仍有一种方法无法对应，具体为`【两个触摸屏的 VID:PID 与 设备描述 完全一致时，即两个完全相同的显示器】`，本文内容对这种情况仍然是无解的，个人认为只能通过硬件端口(/sys/class)来进行识别与调整，本文不涉及该方法(还没吃透)。

## 0、核心：xinput

xinput是Linux下的一款配置测试X输入设备的神器，具有以下功能（我们将会用到的）

> xinput (list)  :  直接键入xinput或者跟上list参数，就会列出本机所有输入设备，包括名称、ID、层级
>
> xinput list --id-only  :  仅仅列出设备ID（序号，每次开机都可能改变）
>
> xinput map-to-output  :  将输入设备映射到输出，比如将触屏映射到某个屏幕
>
> xinput list-props  :  列出某个设备的详细信息，后接参数为设备ID。

## 1、简约：两个完全不同的触摸显示器

`xinput map-to-output "$DEVICE NAME A" PORT-A`

这里对应了两种情况，一是VID:PDI和设备描述符都不同，即毫无关系的两款；二是具有相同的VID:PID，但是设备描述符，这一般是同款芯片配了不同的固件。

首先通过xinput查看所有的输入设备：

```shell
~$ xinput
┌ Virtual core pointer		id=2 [master pointer  (3)]
|	ILITEK TLITEK-TP		id=9 [slave  pointer  (2)]
|	ILITEK Multi-Touch		id=7 [slave  pointer  (2)]
(下略)
```

可以看到`ILITEK ILITEK-TP`和`ILITEK Multi-Touch`显示为两个不同名称的设备，那么不论其VID:PID具体如何，我们都可以按如下方式进行映射：

`xinput map-to-output "ILITEK ILITEK-TP" HDMI-0`

`xinput map-to-output "ILITEK Multi-Touch" HDMI-1`

这种方式的要点是1.必须带英文`""`，2.引号内名称须完整。`map-to-output`所携带的第一个参数为输入设备，不一定要设备id，使用设备名也是能够实现。

## 2、复杂但通用：VID:PID不同的显示器

不论usb设备还是PCI设备，他们都有一个唯一识别符VID:PID，这相当于设备的身份证，同功能的设备，不同的厂商、不同的型号，就会有不同的ID。我们可以通过指定设备的VID:PID，筛选出输入设备的编号id，进行映射。

通过`xinput list-props [id]`可以得到某个设备的详细信息，其中就有十进制的VID,PID，如果这两个参数可以和指定的对应上，那么我们可以提取id映射到屏幕。`list-props`的结果示例如下：

```shell
(后续再补)
```

其中`Device Product ID`一项有两个值，但不像是16进制的VID:PID，经过换算，他们其实是十进制的。利用grep+awk指令筛选出这两个值，和预先设定的比较，确定设备的id。写出来就是这样子：

```bash
#!/bin/bash
# 先通过lsusb/xinput/xrandr 等命令确定如下硬件信息:
# 1、屏幕VID:PID(16进制)和显示接口，多屏重复本段
VIDA=222a
PIDA=0001
PORTA=VGA-0

# 2、先修算出10进制。如果xinput list-props [n] 的“Device Product ID”为16进制的，注释这2行
# 或者这里直接填写Device Product ID里面的结果，先VID后PID。
# 字母O，不是数字0，多屏重复本段
VIDA_O=$((16#$VIDA))
PIDA_O=$((16#$PIDA))

# =========自动处理步骤，请勿随意修改==========
for I in $(xinput list --id-only)
do
# 根据设备ID取其序号
    CUR_FIRST=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $1}'|awk '{print $1}')
    CUR_SECOND=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $2}'|awk '{print $1}')
# 3、屏映射，多屏重复本段
    if [ "$VIDA_O" == "$CUR_FIRST" ] && [ "$PIDA_O" == "$CUR_SECOND" ];
    then
		  xinput map-to-output $I $PORTA
    fi
done
exit 0
```

这个脚本使用`xinput list --id-only`仅列出了设备的id序号，然后轮询所有的设备找出符合要求的编号，最后仍然使用`map-to-output`进行映射。这个脚本易于扩展，如果多个触摸屏只需要将3个有序号的注释后面的一块内容重复、修改名字就可以了。

## 3、[2]的进阶版

前面都是通过shell/bash脚本的方式实现的重映射，如果要自动映射还需要添加自启动。如果设备进行了插拔，这个设备的映射就失效了，需要手动重新跑一跑脚本。我尝试了编写udev-rules文件，当触摸的设备发生变化时就延时启动映射脚本，但无一例外都是失败的，我觉得是udev生效的必xinput更早，无论延时多久都是这样。

在银河麒麟操作系统中我发现了它提供的触摸映射方法，使用的是`pyudev`库，采用第三方的方法实现udev-rules的效果，而且在这里延时不会影响系统的加载顺序，只需要系统额外安装`python3+pyudev`，并且使用desktop文件在开机时启动，即可。

```python
#!/usr/bin/python3
# -- coding: UTF-8 --
# -- Author: Blues --

import pyudev
import os

context = pyudev.Context()
monitor = pyudev.Monitor.from_netlink(context)
monitor.filter_by(subsystem='hid')
for device in iter(monitor.poll, None):
    if device.driver != "hid-multitouch":
        continue
    if device.action == "add" or device.action == "change":
        os.system("/var/my-touchscreen/remap-screen")

```

上面直接贴了麒麟自带的代码，就修改了一下脚本的路径，经过多次验证，在uos下可以正常使用。借此机会我也参照麒麟的代码修改了一下，用户不用看命令行那些多余的东西，只需要点击几个GUI窗口，程序就可以按照*设备名、VID、UID、物理接口*四大特征，自动映射到对应的显示屏上了。