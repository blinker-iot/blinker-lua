# Air72X
这是blinker在Air72X系列模组上的实现，目前支持http鉴权和mqtt连接，具体通信协议未实现。

底层固件地址[LuatOS-Air](https://gitee.com/openLuat/Luat_Lua_Air724U)

## 使用方法

### 环境搭建

下载[Luatools](http://luatos.com/luatools/download/last)

参考[烧录教程](https://doc.openluat.com/wiki/21?wiki_page_id=1923)添加底层固件和本文件夹下的lua脚本到项目

修改main.lua中的以下参数为你需要的值，然后下载到设备

```lua
authKey = "" --点灯云申请的设备authKey
```

即可连接点灯的服务器并收发数据
