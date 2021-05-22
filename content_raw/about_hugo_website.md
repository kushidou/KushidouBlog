---
title: "关于使用HUGO建立博客站点"
date: 2021-03-23T09:15:09+08:00

---

# 关于使用HUGO建立博客

在经历了worldpress的性能消耗和慢速加载后，我现在决定换用hugo+caddy的建站模式。昨天已经完成了caddy2的基础设置，现在开始测试使用hugo。

## hugo的安装与首次创建

安装使用*chocolatey*，一个windows下的仿apt、yum的软件包管理器。安装好chocolatey后，根据hugo官网的内容，`choco install hugo -confirm`安装基础的hugo（好处是不用再配置环境变量了）。

为hugo创建目录，进入后`hugo site new website`，hugo会自动建立它所需要的层级结构。

添加第一个页面，`hugo new xxx/xxx.md'，创建的内容会出现在content下，创建多级目录也适合将来归类。

## 编写文章

hugo的文章是基于markdown文档的，创建的文章会自动加入以下抬头

```TOML
---
title: "$文章标题"
date: $时间
draft: true
---
```

这个可以修改为json或ymal格式，理应可以添加更多项目，这个之后再研究。

## 主题/皮肤

主题放在themes下，我在知乎上找到了一个高赞且顺眼的，[有哪些好看的Hugo主题？ - 飞雪无情的回答 - 知乎](
https://www.zhihu.com/question/266175192/answer/460456938)，文章中附了github连接，那么我们直接git过来就完事了。

## 生成网站

文章+主题都有了，现在可以生成第一个网站了（虽然写这些字的时候，网站还没生成）。`hugo`就能直接产生网页，保存至public文件夹。`hugo server`可以启动一个服务器预览静态网页。
