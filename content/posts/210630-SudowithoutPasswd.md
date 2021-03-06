---
title: 免密码使用sudo
description:
toc: false
authors: kushidou
tags: 
  - Linux
categories: []
series: Linux学习与解决方案
date: 2021-06-30T15:14:40+08:00
lastmod: 2021-07-13T08:43:40+08:00
featuredVideo:
featuredImage:
draft: false
---

记录一种可以免密码使用sudo的方法。

<!--more-->

每次使用sudo提权，常常要输密码太烦了，所以想给自己赋予免密码的特权。

1. 首先登录root用户:   `sudo -i`

2. 这个操作的核心文件是`/etc/sudoers`，可以看到这个文件是只读的，要修改他需要先赋予写入权限。

```bash
chmod 666 /etc/sudoers
```

![文件是只读权限](https://cdn.jsdelivr.net/gh/kushidou/PicLibrary/img/20210705092601.png)

3. 使用vim修改文件，`vi /etc/sudoers`，把当前用户和用户组加入，如图

```bash
# 表示为该用户免密码
yourname	ALL=(ALL:ALL) NOPASSWD:ALL
# 表示为该用户组免密码
%yourname	ALL=(ALL:ALL) NOPASSWD:ALL
# 不用严格按照次形式，与你的这个文件中root的格式对应即可。
```

4. `:wq`保存，把sodoers改回只读 

```bash
chmod 440 /etc/sudoers
```

![文件修改的内容](https://cdn.jsdelivr.net/gh/kushidou/PicLibrary/img/20210705092637.png)

5. 完成\~\~\~ 把终端关掉再次打开就应该能看到效果了。

>  **PS. 不可使用sudo chmod**
>
> 一定要直接sudo -i进入root用户，如果使用sudo chmod以普通用户的身份修改sudoers文件的话，改完会发现无法使用sudo指令把权限改回去了，提示“任何人可读写，无法找到有效的sudoers”。其实还有一种更加安全的操作，但是那个编辑器用起来没有vim顺手，
>
> 

参考：https://blog.csdn.net/wxqee/article/details/72718869