---
title: Linux多显示器触屏调试与暂行解决方案
description: Linux with multi touch screen
toc: true
authors: Kushidou
tags: 
  - Linux
  - Deepin/UOS
  - 触摸屏
categories: []
series: Linux学习与解决方案
date: 2021-03-11
lastmod: 2021-04-28
featuredVideo:
featuredImage:
draft: false
---

由于需要使用新创平台配合多个显示器，触摸屏经常出现不准的情况。经过多次的查阅资料、测试和整合，总结了一个解决触摸的方法。一些测试过程中的弯路也保留了，作为记录。

<!--more-->

*2021-03-22更新部分内容*
*2021-04-28再次更新内容*

## 问题来源

最近客户要求使用信创平台，即国产CPU+国产操作系统平台。现在这方面主要使用的操作系统为麒麟和通信uos。这两个的本质都是debian系的，所以很多地方的调试与使用都可以按乌班图的经验来操作。一款产品要使用三块显示器，其中两块是触屏。屏幕通过R5 420显卡，都转换成VGA连接。
接入设备后，发现触摸屏默认是映射到全屏幕，在任何显示器上操作都会按排列顺序在对应的区域触发。所以需要给每个显示器分别映射触摸。映射的基本指令为

`xinput map-to-output $触屏设备id $显示屏名称`

> 2021-04-28更新
> 
> `xinput map-to-output`指令支持触摸屏名称作为参数，比如我通过`xinput`指令看到有一个触摸屏的设备名称为`ILITEK XXXX`，那么我映射的时候直接输入
> > `xinput map-to-output "ILITEK XXX" HDMI-1`
> 

## 尝试解决
- 首先使用xinput查看触摸设备及其序号$id。这里可以看到多个设备，可以通过单独插拔的方式找到每个设备。
- ~~然后`xinput list-props $id`查看设备的VID，这个在后续自动化处理有用。~~
- `xrandr`查看`$显示器名称`

## 自动化处理

```bash
# 2021-04-28更新：
# 本部分后面的都可以不看了！
xinput map-to-output "DEVICE_NAME" DISPLAY
# 把这一段写入可以自动执行的脚本里面，比如/etc/rc.local, ~/.bashrc, /etc/profile, 
# 以及制作成service等。有几个触摸屏就写几行指令，比下面的简洁了太多~
```

**仅作归档！下面这些方法过于繁琐！**

利用VID和显示器名称作为参数，运行下面的脚本，或者直接手动执行重映射，即可解决触屏作用范围问题。`bash this.sh VID1 VID2 ScreenID`

```shell
#!/bin/bash
# 这段适合触屏硬件id不同的情况，如果遇到id不同需要其他方法。
# 2021-03-22更新：在前几天的实操中，发现字符串比较部分出现了问题，这个方案的可行性有待进一步探索。现在采用另一种方案。
MYID_FIRST=$1
MYID_SECOND=$2
OUT_PUT=$3

for I in $(xinput list --id-only)
do
#[1]
    CUR_FIRST=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $1}'|awk '{print $1}')
    CUR_SECOND=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $2}'|awk '{print $1}')
    if [ "$MYID_FIRST" == "$CUR_FIRST" ] && [ "$MYID_SECOND" == "$CUR_SECOND" ];
    then
        MY_INDEX=$I
        break;
    fi
done

xinput map-to-output $MY_INDEX $OUT_PUT

#./this.sh VID VID HDMI2
#./this.sh VID VID HDMI1
```

```shell
#!/bin/bash
# 2021-03-22更新：这种方案只要四行就能实现一块的映射，需要时只要复制这个代码块即可，修改DEVICE_NAME 和 SCREEN_NAME 。如果名称中带有重复的部分，可以再加一个grep -v xxxx来排除关键词。但是如果遇到屏幕完全重名的情况，就不可解了。
TOUCH_ID=$(xinput | grep -iw DEVICE_NAME)
TOUCH_ID=$(echo ${TOUCH_ID#*id=})
TOUCH_ID=$(echo ${TOUCH_ID%% *})
xinput map-to-output $TOUCH_ID SCREEN_NAME
```



此方法可以在直到触屏VID后，（一般多显示器使用的是不同的型号），~~使用自启动rc.local开机执行重映射指令，保证每次开机都能准确找到屏幕，且适用于系列产品不用单独找id~~。

经测试rc.local由于只在开机执行，如果分辨率在开机的时候改变了（比如用了转接头分辨率会重新调整），映射关系还是会出错。我决定用一个取巧的办法，把执行脚本的命令放在`~/.bashrc`中，这样只需要打开一次终端，就可以实现屏幕重新映射。

## 后续问题

1. 当屏幕参数改变，如调整分辨率、调整顺序、插拔屏幕、换屏幕等，都会引发映射的失效，需要再次执行脚本。
2. 当屏幕发生改变，需要调整脚本中固化的参数，或调整执行脚本的输入参数
3. 如果屏幕使用了相同的驱动ic，会看到同样的VID，这样子会难以区分。这时候把[1]处的判断条件改成按名称或者其他不同的参数，也能够自动适配。但两块完全一样的屏幕，现阶段还没想到解决方法，只能自己手动映射试试了。

## 触屏校准（如果需要）

网上说的利用校准来区分多触摸屏的方法是**完全错误**的，仅适用于他们的产品而不是通用解决方案，很多人就是抄来抄去而已。但是如果遇到触摸偏移，还是有需要进行校准的，校准方法为（最后一步需要甄别，有些系统没有这个目录）

- `sudo apt install xinput-calibrator`，需要更新源
- `sudo xinput_calibrator`
- 将校准信息保存到`/usr/share/X11/xorg.conf.d/10-evdev.conf`的"Driver evdev”下面一行，重启生效。

## 参考：
[1]https://blog.csdn.net/yuan_da_xian/article/details/72864008
[2]https://blog.csdn.net/qq_33406883/article/details/106649087
[3]https://segmentfault.com/a/1190000020334077