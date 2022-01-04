---
title: 在Linux环境下修改用户名和主目录
description:
toc: false
authors: kushidou
tags: 
  - Linux
categories: []
series: Linux学习与解决方案
date: 2021-12-03T09:01:23+08:00
lastmod: 2021-12-03T09:01:23+08:00
featuredVideo:
featuredImage:
draft: false
---

如何在Linux下完整修改当前用户名和主目录，还不影响其他文件？

<!--more-->

Linux的用户名是一个用户的字符串表示，是可以修改的。只要用户的id不改变就不会被系统认作新用户，所有的权限都可以继承。下面介绍如何修改用户的名称、所属组，并更改主目录的名称与对应关系。

## 一、进入“单用户模式”

为了修改用户名时不影响程序运行，需要把当前用户打开的所有程序都关闭。该方法可以快速注销当前用户。

```bash
init  0
执行后输入当前用户密码
进入黑屏终端后需要输入root密码，可以使用sudo passwd 提前设置
```

对于屏蔽init指令的系统，一般情况下注销用户就可以了，但是有些GUI桌面环境就是以当前用户的身份运行的，所以提供如下几个方式关闭当前用户，挨个尝试即可。

```bash
# 1 桌面环境中点击注销

# 2 杀掉当前用户所有进程
pkill -kill -u old_name
# 3 杀掉进程后可能桌面重启，关闭Lightdm管理器
#     Ctrl + Alt + F2 进入第二页面，以root用户登录（可能需要提前设置root密码）
systemctl stop lightdm
#     然后再次执行第二步
```

##  二、修改信息

`init 0`可以直接进入黑屏的终端，或者使用 `ctrl + alt + f2`进入（远程连接可以），以root用户登录。

```bash
# 1 修改组的名称
groupmod -n new_name old_name
# 2 修改用户名    -l 改名字  -d 改目录  -g 改组
usermod -l new_name -d /home/new_name -g new_name old_name
# 3 修改主目录
mv /home/old_name /home/new_name
```

最后回到图形化界面，输入`init 5` ，或者重启电脑。

修改完主目录后记得检查是不是有其他软连接指向旧目录，需要进行更新，否则还会遇到问题。

## 参考：

\# [linux用户家目录怎么修改,Linux 更改用户名,用户组和主目录](https://blog.csdn.net/weixin_30016961/article/details/116543982)

\# [菜鸟教程-usermod指令](https://www.runoob.com/linux/linux-comm-usermod.html)

\# [linux组的管理：修改组名字，删除组，使用sudo权限](https://blog.csdn.net/weixin_40001125/article/details/88903115)