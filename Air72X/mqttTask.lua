module(..., package.seeall)

require "misc"
require "mqtt"
require "mqttOutMsg"
require "mqttInMsg"
require "http"
local ready = false
local authKey = "86c34c2ab1c2" --点灯云申请的设备authKey
local serverAdress = "http://iot.diandeng.tech/api/v1/user/device/diy/auth?authKey=" --http鉴权地址
mqttAdress, deviceName, iotId, iotToken = ""
--- MQTT连接是否处于激活状态
-- @return 激活状态返回true，非激活状态返回false
-- @usage mqttTask.isReady()
function isReady()
    return ready
end
--获取设备连接信息
--传入参数：authKey为点灯云申请的设备authKey
--传出参数：成功为true以及连接信息，失败为false
local function getDeviceInfo(authKey)
    http.request(
        "GET",
        serverAdress .. authKey .. "&protocol=mqtt",
        nil,
        nil,
        nil,
        nil,
        function(result, prompt, head, body)
            if result and body then
                if body and json.decode(body) then
                    authdata = json.decode(body)
                    log.info(
                        "获取设备信息成功",
                        authdata.detail.host,
                        authdata.detail.deviceName,
                        authdata.detail.iotId,
                        authdata.detail.iotToken
                    )
                    _, _, protocal = authdata.detail.host:find("://(%a+.%a+.%a+)")
                    mqttAdress, deviceName, iotId, iotToken =
                        protocal,
                        authdata.detail.deviceName,
                        authdata.detail.iotId,
                        authdata.detail.iotToken
                end
            else
                log.info("获取设备信息失败")
            end
            sys.publish("HTTP_PASS")
        end
    )
end
--启动MQTT客户端任务
sys.taskInit(
    function()
        local retryConnectCnt = 0
        while true do
            if not socket.isReady() then
                retryConnectCnt = 0
                --等待网络环境准备就绪，超时时间是5分钟
                sys.waitUntil("IP_READY_IND", 300000)
            end

            if socket.isReady() then
                getDeviceInfo(authKey)
                sys.waitUntil("HTTP_PASS", 3000)
                log.info("authKey", mqttAdress, deviceName, iotId, iotToken)
                if mqttAdress and deviceName and iotId and iotToken then
                    local imei = misc.getImei()
                    --创建一个MQTT客户端
                    local mqttClient = mqtt.client(deviceName, 600, iotId, iotToken)
                    local mqtt_topic = "/device/" .. deviceName .. "/r"
                    local mqtt_topic_pub = "/device/" .. deviceName .. "/s"
                    --阻塞执行MQTT CONNECT动作，直至成功
                    if mqttClient:connect(mqttAdress, 1883, "tcp") then
                        retryConnectCnt = 0
                        ready = true
                        --订阅主题
                        if mqttClient:subscribe({[mqtt_topic] = 0}) then
                            mqttOutMsg.init()
                            --循环处理接收和发送的数据
                            while true do
                                if not mqttInMsg.proc(mqttClient) then
                                    log.error("mqttTask.mqttInMsg.proc error")
                                    break
                                end
                                if not mqttOutMsg.proc(mqttClient) then
                                    log.error("mqttTask.mqttOutMsg proc error")
                                    break
                                end
                            end
                            mqttOutMsg.unInit()
                        end
                        ready = false
                    else
                        retryConnectCnt = retryConnectCnt + 1
                    end
                    --断开MQTT连接
                    mqttClient:disconnect()
                    if retryConnectCnt >= 5 then
                        link.shut()
                        retryConnectCnt = 0
                    end
                end
                sys.wait(5000)
            else
                --进入飞行模式，20秒之后，退出飞行模式
                net.switchFly(true)
                sys.wait(20000)
                net.switchFly(false)
            end
        end
    end
)
