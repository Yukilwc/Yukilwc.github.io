---
title: 'ElementUI速查手册'
categories:
- 前端
tags: 
- ElementUI UI框架
description: 作为快速查询，复制粘贴模板用的手册
cover: https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/51842023_p0.jpg
---
# 概要
##  意义

# 安装
## 按需加载的配置
### 依赖安装
```
npm install babel-plugin-component -D
```
### babel配置
此处仅提供了vue-cli3构建项目的修改，如果是其他方式构建的工程，可以参考[官方文档](https://element.eleme.cn/#/zh-CN/component/quickstart)。

修改babel.config.js文件如下:
``` javascript
module.exports = {
  presets: [
    '@vue/cli-plugin-babel/preset',
    [
      "@babel/preset-env", {
        "modules": false
      }
    ]
  ],
  plugins: [
    [
      "component",
      {
        "libraryName": "element-ui",
        "styleLibraryName": "theme-chalk"
      }
    ]
  ]
}
```
### 按需引入
具体的组件名列表，可以在官方文档网站上查询.
``` javascript
import Vue from 'vue'
import {Button,Select} from 'element-ui'
Vue.use(Button)
Vue.use(Select)
```
## 多语言

# 问题汇总
## select组件多选问题
在使用 select的多选功能时，需要初始化select框，为其注入一个初始的数组，发现用数组为select model赋值后，出现了选择，删除的失效问题，代码和解决如下。

首选明确一些参数的意义:
1. el-select
   * v-model: 是双向绑定值，选择后，会将选择的option的value字段，写入对应data中，其可以是字符串，也可以是对象。当多选模式下，其映射一个数组。 
2. el-option
### 问题代码
``` html

```
### 解决