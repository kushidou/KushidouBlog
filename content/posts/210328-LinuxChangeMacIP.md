---
title: Linux修改mac地址
description:
toc: false
authors: kushidou
tags:
  - Linux
  - 网络
categories: []
series: Linux学习与解决方案
date: 2021-03-28
lastmod: 2021-03-28
featuredVideo:
featuredImage:
draft: false
---

当Linux的图形界面没有或失效的时候，该如何更改mac地址？

<!--more-->

# Linux调整网卡MAC地址（指令）
有的时候需要使用欺骗的方法为电脑设置新的mac，比如存在上网网卡限制，或者想要隐藏自己的真实mac地址。这里列举三种修改mac的方法，适用于Debian系的Linux，其他的应该类似。

## 方法一：ifconfig

```bash
# ifconfig    查看网卡名称$NAME
# 需要sudo权限
ifconfig $NAME down
ifconfig $NAME hw ether $NEW_MAC
ifconfig $NAME up
# 使用ifconfig检查有没有改变
```

## 方法二：macchanger

`sudo apt install macchanger`，安装过程提示是否自启，随便。

```bash
ifconfig $NAME down
macchanger -m $NEW_MAC $NAME
ifconfig $NAME up
```

ps:macchanger可以附加多种参数，如-m指定mac地址，-s查看状态，-r随机地址

## 备注：
以上两种方法是软件层面的修改，不会对硬件造成损伤，重启之后就能恢复如初。如果是要长期有效，可以把这些命令写入脚本开机自启。除了这两个，还有另一种软修改的方法，因为我总是提示失败就遗忘了。

有些方法会提到修改/etc目录下的文件实现MAC地址的修改，但是我一个文件都没找到（UOS），这个是因系统而异的，不同的发行版可以选择性的编译这些文件，就会造成有人有有人没有，因为没有实践，所以就不写在这里了。


## 方法三：ethtool（慎用）

以上方法都失效，可以直接修改网卡的物理MAC地址，修改后无法恢复，慎用

```bash
# 首先检查mac是否支持修改
ethtool -i $NAME
# 如果  supports-eeprom-access: no，大概率不支持修改

# 查看网卡的mac寄存器
ethtool -e $NAME
# 如果无法读取，大概率不支持修改

# 修改mac，按字节修改
ethtool -E $NAME offset 0 value 0xAA
ethtool -E $NAME offset 1 value 0xBB
ethtool -E $NAME offset 2 value 0xCC
...共六行
# 如果修改无效，则驱动不支持修改
```

## 如果以上方法都无法修改，则建议申请新的ip。。。

*<font size="1">文章首发于<a href="small09.top" target="前往火柴盒" title="前往Kushidou个人博客" rel="noopener">香风家的小别墅</a>，转载请携带出处。</font>*


