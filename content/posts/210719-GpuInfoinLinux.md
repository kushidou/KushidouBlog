---
title: Linux中获得AMD显卡的状态信息
description:
toc: true
authors: kushidou
tags: 
  - Linux
  - 显卡
categories: []
series: Linux学习与解决方案
date: 2021-07-19T11:00:07+08:00
lastmod: 2021-07-19T13:35:00+08:00
featuredVideo:
featuredImage:
draft: false
---

在Linux下获得AMD GPU的状态和温度信息。

<!--more-->

在Linux下如果要查看Nvidia GPU的状态信息，可以使用Nvidia驱动自带的工具。而AMD显卡一般都是使用的开源驱动，这种情况下如何获得显卡的状态和占用呢？

*文章部分图片之后再附*

## 1、获取GPU信息

如需获得GPU的信息（型号、驱动）等，如果系统提供类似*“设备管理器”*的工具可以打开查看。或者就是用`lspci`指令查看。

```bash
# 获得所有PCIe设备，在其中找到AMD GPU
[exam@ple]:~$ lspci
00:02.0 VGA compatible controller: xxxxxxxx

[exam@ple]:~$ lspci -v -s 00:02.0
# 这里就会显示显卡的具体信息了，包括型号、驱动等，之后补充
```

## 2、GPU占用率

显卡占用率是一个能反映负载的直观指标，AMD显卡可以通过安装`radeontop`软件查看。

![radeontop界面](https://cdn.jsdelivr.net/gh/kushidou/PicLibrary/img/20210719133426.png)

最上面是GPU管道使用，大概类似于总体使用率的东西；最下面是内存使用率，使用sudo权限能看到更多信息。其他项目可以到radeontop的[Github页面](https://github.com/clbr/radeontop)查看。

## 3、温度
特指GPU温度。查阅这篇文章所涉及的知识点的最初目的，也是确认机箱过热是否是GPU的问题。

GPU温度使用第三方软件查看，并使其实时更新。查看温度使用`sensors`指令，通过安装`lm-sensors`实现。执行sensors时只会显示一次，我们可以利用watch指令定时刷新温度显示：

```bash
watch -n 2 sensors
# 每隔2秒执行sensors指令显示结果
```

!\[watch执行结果\](图片占位)