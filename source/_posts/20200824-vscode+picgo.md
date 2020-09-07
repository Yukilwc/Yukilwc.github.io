---
title: 'VsCode+Picgo+阿里云OSS搭建博客图床'
categories:
- 运维
tags: 
- OSS
- 博客工具
description: 记录基本的流程配置与一些需要注意的点
cover: https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/1599308368179.webp
---
# 概要
## 意义
图片是博客文章不可缺少的表现元素，没有图片的文章列表，文章内容，总给人干涩单调感。
而使用markdown编写博客时，需要以超链接的形式，插入图片。
最开始是打算将图片存放在博客本身编译的代码中，如static文件夹，发现带来的问题很多
1. 大量的图片，难以管理和存储
2. 在写文章时，无法快速，高效，无缝的插入图片
3. 每次的发布，除非是使用git发布，否则代码包过大，并且损耗购买的轻量应用服务器的资源。

于是为了在写文章时快速方便的插入图片，以此为目的，搭建Vscode+Picgo+阿里云OSS的图片上传。

# 阿里云OSS购买与配置
## 购买
因为轻量应用服务器是在阿里云购买了，因此OSS服务也选择阿里云。
打开阿里云官网，存储与网络，对象存储OSS，进入购买页,如下图
![订单选择](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200905234810.webp)

参照购买页，有些需要注意的地方
* 购买的是资源包，相当于存储空间，而另外的一些服务，如外网请求流量，图片压缩等功能，需要另外计费，因此资源包购买后，依然会继续扣除费用，可以账户里充值下，防止欠费。
* 资源包类型选择标准(LRS)服务即可，其他的都是些业务相关的服务
* 地域方面，购买中国大陆通用

完成订单后，就可以进入OSS对应的工作台了。
## 创建空间
在工作台创建bucket

![选择创建bucket](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906100713.webp) 

在配置页面中，因为仅仅是想做个博客图床，因此额外服务能不选的都不选，防止额外的收费。
其中读写权限选择了私有，这在后面更加具体的配置。

![创建配置页面](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906100823.webp)

创建完成的bucket如下所示：

![bucket工作台](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906103014.webp)

在上图bucket管理工作台目录的功能：
* 概览： 查看流量，域名
* 文件管理：管理上传的图片，如批量删除
* 权限管理： 设置bucket的可访问性，如提供给一个子账号访问权限等
* 基础设置： bucket的基础管理，如删除，配置静态页面托管
* 其他的暂时没具体了解使用

## 配置OSS的访问权限
此时，bucket创建完成，可以通过阿里云网页，或者OSS访问工具，比如[文档](https://help.aliyun.com/document_detail/44075.html?spm=a2c4g.11186623.2.29.709b3470qM2uUf#concept-owg-knn-vdb)中提供的官方工具ossbrowser,ossutil，或者一些第三方的资源读写工具，例如picgo进行bucket的读写。

在使用工具访问时，本质是通过调用api来访问bucket，因此需要提供accesskey相关的信息，我们并不想直接生成一个管理员的accesskey，因为管理员的accesskey具有阿里云api的完全访问权限，这很不安全，因此这里先创建一个子账号。

搜索栏中搜索RAM访问控制，进入RAM控制台,打开人员管理目录下，用户页面

![搜索](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906104527.webp)

添加用户，选择编程访问

![创建用户](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906110137.webp)

进入刚创建的用户页面，点击创建accesskey，即可获取用户的AccessKey ID和AccessKey Secret

![点击创建accesskey](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信图片_20200906110507.webp)

最后一步，选择权限管理，添加个人权限，选择AliyunOSSFullAccess权限策略，进行添加即可

![添加权限](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906111004.webp)

通过上述步骤，即创建了一个拥有OSS管理权限的子账号，并获取了其accesskey信息。

## 其他配置与服务
### 读写权限配置
在创建bucket时，选择了私有的读写权限，因此，任何外网的访问，都需要通过accesskey加上阿里云api进行访问，要想生成的图片让浏览器直接访问，应该进入bucket工作台，权限管理，读写权限配置，将权限修改为公共读，如此，生成的图片在外网可以直接通过url访问，而不需要accsskey获取图片资源。

![修改读写权限，提供外网直接访问](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906111739.webp)

### 防止盗链
由于读写权限修改成了公共读，外网只要知道资源的url，就可以直接访问，而不需要accesskey，因此，容易被其他网站直接盗用资源url，导致流量的损失。所以需要进行防止盗链的配置，限制生成的图片url仅仅只能在限定的域名中访问才可生效。

进入bucket工作台，权限管理，防盗链配置，配置正则的白名单域名，以及设置不允许空referer.此时，非白名单域名就无法访问图片了。当然，如果对方非得想要访问，伪造请求头之类的也是无法防住的。

![防盗链配置](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200906112227.webp)

# Picgo配置
## 安装
因为使用vscode编辑markdown，因此图片上传工具选择vscode的picgo插件，搜索并安装即可

![picgo安装](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/6c6f14941ab0b9496ffc186984816aa.webp)

## 配置
打开picgo的extension setting,开始进行配置如下：
* 配置当前图床为阿里云![当前图床配置](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/1c8f8bcbfe34e081e68b256daefa5ff.webp)
* 配置access信息,此信息在配置阿里云子账号时已经获取![access配置](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/a93f656c8a9d1a8db47867d4cbd5976.webp)
* 配置，地区，存储路径等信息,其中Area，Bucket，Custom Url都可以在bucket控制台概览中看到，而Path则需要自己去文件管理中建立blog/images文件夹.![地区，路径，url配置](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/f1e975200e1d731f159953b5b6a54d0.webp)

一些注意事项：
* 如果报错了，请检查accesskey和secret中是否有空格，特别是开头部分。
* 路径相关的请按照配置来，多出的'/'等会影响拼接导致报错。

## 使用
常用快捷键：
* ctrl+alt+E 从文件管理器中上传图片，并生成markdown图片链接

# 图片压缩
图片不压缩的话，损耗网络资源太严重，产生很多非必要的费用，而阿里云自带的压缩是按次数收费的，所以找其他压缩工具进行本地压缩。
## 选择格式
选择图片格式为webp，无降级策略，不考虑兼容性问题。
webp有出色的压缩比率,如下为百分之90品质的压缩

![bac822cdfcd54daecd9907ddb88d37d](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/bac822cdfcd54daecd9907ddb88d37d.webp)

如下是100%品质的压缩

![1ccf90180bd138c5e7de37dbed8b1d0](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/1ccf90180bd138c5e7de37dbed8b1d0.webp)

最终定型，出了首页banner大图为100%品质压缩，其他图片均使用90%webp压缩.

## 推荐的压缩工具
当前使用一个在线无需上传的压缩网站[webp2jpg](https://renzhezhilu.gitee.io/webp2jpg-online/), 其[github地址](https://github.com/renzhezhilu/webp2jpg-online)

![微信截图_20200908005217](https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/微信截图_20200908005217.webp)

# 后续计划
## 图片上传过程中的自动压缩的vscode插件