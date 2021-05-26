---
title: deepin和UOS，快捷方式，开机自启动
description:
toc: false
authors: kushidou
tags: 
  - Linux
  - Deepin/UOS
categories: []
series: Linux学习与解决方案
date: 2021-04-29
lastmod: 2021-04-29
featuredVideo:
featuredImage:
draft: false
---

修正触屏的脚本总是运行失败，于是找到在Deepin下能够在桌面启动后自动运行的方法。这样的触屏映射就稳定了。

<!--more-->

## 桌面快捷方式

deepin的桌面快捷方式是以`*.desktop`文件的形式实现的，所以我们需要添加自定义快捷方式的话，只要在桌面添加要给desktop格式的文本文件，编辑内容

```
[Desktop Entry]
Name=ddd
Exec="/usr/sbin/xx.sh"
Type=Application
```

其中`Desktop Entry`表示声明该文件为快捷方式文件。`Name`是这个文件要显示的名字，设置了之后就可以隐藏原名称和扩展名。`Exec`是程序的启动脚本，或者启动指令。`Type`是程序类型，在开始菜单的分类中可以体现。以上四行是必须要有的参数，还有一些其他的参数不影响执行。Exec的脚本必须赋予777权限以执行。

把这个文件放在`~/Desktop`，就可以看到桌面上多了一个快捷方式了。

## 开始菜单

`sudo cp ~/Desktop/刚刚的.desktop /usr/share/applications`，过一会或者注销重新登录就能看到开始菜单的响应类型下出现这个快捷方式了。

## 开机自动执行

`cp ~/Desktop/刚刚的.desktop ~/.config/autostart`

需要这个的原因主要是我执行触摸屏映射的指令经常会在桌面启动前（`lightdm.service`）执行，导致error从而无法进入桌面，将脚本放进`/etc/profile.d`之后第二天就失效了，所以需要一个在登录桌面后就实现自动执行的功能，多种方法对比下来还是放进桌面环境的开机自启文件夹比较靠谱。这样一般会在进入桌面后5-10秒自动执行，稳定性大幅提高。
