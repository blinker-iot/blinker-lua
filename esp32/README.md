# ESP32-C3
这是blinker在LuatOS-ESP32上的实现，目前支持http鉴权和mqtt连接，具体通信协议未实现。

底层固件开源地址[LuatOS-ESP32](https://github.com/dreamcmi/LuatOS-ESP32)

## 使用方法

### 环境搭建

下载底层仓库的releases版本固件解压。

下载[Luatools](http://luatos.com/luatools/download/last)

参考[烧录教程 - LuatOS 文档](https://wiki.luatos.com/boardGuide/flash.html)添加底层固件和本文件夹下的lua脚本到项目

修改main.lua中的以下参数为你需要的值，然后下载到设备

```lua
ssid = "" --wifi名

password = "" --wifi密码

authKey = "" --点灯云申请的设备authKey
```

即可连接点灯的服务器并收发数据
