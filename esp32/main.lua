PROJECT = "Blinker-LuatOS"
VERSION = "1.0.0"
sys = require("sys") --系统库必须引用
wifiLib = require("wifiLib") --wifi操作相关的函数封装
httpLib = require("httpLib") --http操作相关函数封装

ssid = "" --wifi名
password = "" --wifi密码
USE_SMARTCONFIG = false --是否使用SMARTCONFIG配网
authKey = "" --点灯云申请的设备authKey
serverAdress = "http://iot.diandeng.tech/api/v1/user/device/diy/auth?authKey=" --http鉴权地址

--获取设备连接信息
--传入参数：authKey为点灯云申请的设备authKey
--传出参数：成功为true以及连接信息，失败为false
local function getDeviceInfo(authKey)
    local result, code, data = httpLib.request("GET", serverAdress .. authKey .. "&protocol=mqtt")
    if result == false or code == -1 or code == 0 then
        log.error("获取设备信息失败 ", data)
    else
        if data and json.decode(data) then
            authdata = json.decode(data)
            log.info("获取设备信息成功", authdata.detail.host, authdata.detail.deviceName, authdata.detail.iotId, authdata.detail.iotToken)
            return true, authdata.detail.host, authdata.detail.deviceName, authdata.detail.iotId, authdata.detail.iotToken
        end
    end
    return false
end
--新建一个任务，因为wait操作必须在任务中运行
sys.taskInit(
    function()
        if USE_SMARTCONFIG == true then
            log.info("开机中 等待配网...")
            local connectRes = wifiLib.connect()
            if connectRes == false then
                log.info("配网失败 重启中...")
                rtos.reboot()
            end
        else
            log.info("开机中")
            local connectRes = wifiLib.connect(ssid, password)
            if connectRes == false then
                log.info("联网失败重启中...")
                rtos.reboot()
            end
        end
        local result, host, deviceName, iotId, iotToken = getDeviceInfo(authKey)
        if result then
            --新建一个mqtt客户端
            local mqttc = espmqtt.init({uri = host, client_id = deviceName, username = iotId, password = iotToken, keepalive = 180})
            local mqtt_topic = "/device/" .. deviceName .. "/r"
            local mqtt_topic_pub = "/device/" .. deviceName .. "/s"
            local online = [[ {"state":"online"}]]--心跳信息，表明设备在线，现在好像还不对
            while true do
                if mqttc then
                    log.info("mqttc", "what happen")
                    local ok, err = espmqtt.start(mqttc)
                    log.info("mqttc", "start", ok, err)
                    if ok then
                        while 1 do
                            local result, c, ret, topic, data = sys.waitUntil("ESPMQTT_EVT", 30000)
                            if result == false then
                                -- 没消息, 没动静
                                log.info("mqttc", "wait timeout")
                                espmqtt.publish(mqttc, mqtt_topic_pub, online)
                            elseif c == mqttc then
                                -- 是当前mqtt客户端的消息, 处理之
                                if ret == espmqtt.EVENT_CONNECTED then
                                    -- 连接成功, 通常就是定义一些topic
                                    log.info("订阅主题")
                                    espmqtt.subscribe(mqttc, mqtt_topic)
                                elseif ret == espmqtt.EVENT_DATA then
                                    -- 服务器来消息了, 如果data很长(超过4kb), 可能会分多次接收, 导致topic为空字符串
                                    log.info("mqttc", topic, data)
                                    --可以在这里处理收到的消息
                                else
                                    -- qos > 0 的订阅信息有响应, 会进这个分支
                                end
                            else
                                log.info("mqttc", "not this mqttc")
                            end
                        end
                    else
                        log.warn("mqttc", "bad start", err)
                    end
                    espmqtt.destroy(mqttc)
                end
            end
        end
    end
)

sys.run()
