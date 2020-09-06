---
title: 'ElementUI速查手册'
categories:
- 前端
tags: 
- ElementUI UI框架
description: 作为快速查询，复制粘贴模板用的手册
cover: https://blog-misaka1033.oss-cn-beijing.aliyuncs.com/blog/images/84095735_p0_master1200.webp
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
# 输入类组件
## select
首选明确一些参数的意义:
### 参数
1. el-select
  * v-model: 是双向绑定值，选择后，会将选择的option的value字段，写入对应data中，其可以是字符串，也可以是对象。当多选模式下，其映射一个数组。 
2. el-option
  * value: 是选中后，注入到model中的值，其可以是对象。
  * label：是选中后，填充到输入框中的文本。
3. slot: 是显示在下拉列表中的项.
### 多选
``` html
      <el-select v-model="model" @change="select" multiple>
        <el-option
          v-for="(item,index) in options"
          :key="index"
          :label="item.label"
          :value="item"
        >{{item.listItem}}
        </el-option>
        <div slot="empty">空</div>
      </el-select>
```
``` javascript
export default {
  data() {
    return {
      ruleForm: {
        model: [],
      },
      options: [
        {
          label: "label1",
          listItem: "listItem1",
          value: "value1",
        },
        {
          label: "label2",
          listItem: "listItem2",
          value: "value2",
        },
     ],
    };
  },
  mounted() {
    // 此处初始化model数据,对数组操作易产生问题，推荐使用this.$set
    this.ruleForm.model.push({
      label: "label2",
      listItem: "listItem2",
      value: "value2",
    });
  },
  methods: {
    select(e) {
      console.log("触发选中", e, this.model);
    },
  },
};
```

# 展示类组件
## 表格
### 模板
``` html
<el-table
  ref="table"
  :data="tableData"
  height="250"
  border
  stripe
  highlight-current-row
  :row-class-name="tableRowClassName"
  @current-change="handleCurrentChange"
  @selection-change="handleSelectionChange"
  @row-dblclick=""
  @row-click=""
  @sort-change=""
  >
  <!-- 多选列 -->
  <el-table-column
    type="selection"
  >
  </el-table-column>
 
  <!-- 序号列 -->
  <el-table-column
    type="index"
  >
  </el-table-column>
  <el-table-column
    label="列名"
    width="100"
    min-width="100"
    show-overflow-tooltip
    sortable="custom"
    fixed
    >
    <template v-slot="scope">
      <span>{{scope.row.name}}</span>
    </template>
  </el-table-column>
</el-table>
```

``` javascript
export default {
  mathods: {
    tableRowClassName({row,rowIndex}) {
      return 'common-blue-row'
    },
     handleCurrentChange() {

     },
    handleSelectionChange() {

    },
    //  table实例方法
    tableInstance() {
      // 设定当前单选的行，如果为空，则取消选择
      this.$refs.table.setCurrentRow(row)
      // 添加选中行
      this.$refs.table.toggleRowSelection(row)
      // 清空选中
      this.$refs.table.clearSelection()

    }

  }
}
```

### 一些参数解析
### 事项
* 如果相对单元格添加样式控制，建议在template中添加，当然也可以使用
* 一些浏览器下列边框对不齐问题
* 多级表头： 只需要用el-table-column嵌套el-table-column即可实现
* 合并单元格时，注意一方面要把目标单元格扩充，另一方面要把被占据的单元格归零处理，否则会发生错乱。
* 未记录实践功能： 筛选功能,展开行功能,树形数据，懒加载，表尾合计行
# 问题汇总
