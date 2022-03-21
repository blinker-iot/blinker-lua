-- Blinker组件
-- 使用:
--button1 = ButtonWidget("testKey", function (msg)
--    print(msg)
--end)

-- TODO 将组件与消息服务关联起来

local json = require("cjson")

BlinkerWidgets = {}
BlinkerWidgets.__index = BlinkerWidgets

setmetatable(BlinkerWidgets, {
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function BlinkerWidgets:_init(key, func)
    self.key = key
    self.func = func
    self.state = {}
end

-- 反馈：组件 -> App
function BlinkerWidgets:update()
    local message = {}
    message[self.key] = self.state

    local result = json.encode(message)
    -- TODO 将result发送给app
end

-- 执行: App -> 组件
-- 将收到的消息往组件绑定的回调函数传递
function BlinkerWidgets:handler(msg)
    self.func(msg)
end


-- Button组件
ButtonWidget = {}
ButtonWidget.__index = ButtonWidget

setmetatable(ButtonWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function ButtonWidget:turn(swi)
    self.state["swi"] = swi
    return self
end

function ButtonWidget:text(text)
    self.state["text"] = text
    return self
end

function ButtonWidget:icon(icon)
    self.state["ico"] = icon
    return self
end

function ButtonWidget:color(color)
    self.state["clr"] = color
    return self
end


-- Text组件
TextWidget = {}
TextWidget.__index = TextWidget

setmetatable(TextWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function TextWidget:text(swi)
    self.state["tex"] = swi
    return self
end

-- Number组件
NumberWidget = {}
NumberWidget.__index = NumberWidget

setmetatable(NumberWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function NumberWidget:text(text)
    self.state["tex"] = text
    return self
end

function NumberWidget:value(value)
    self.state["val"] = value
    return self
end

function NumberWidget:unit(unit)
    self.state["uni"] = unit
    return self
end

function NumberWidget:icon(icon)
    self.state["ico"] = icon
    return self
end

function NumberWidget:color(color)
    self.state["clr"] = color
    return self
end

function NumberWidget:max(num)
    self.state["max"] = num
    return self
end

-- Range组件
RangeWidget = {}
RangeWidget.__index = RangeWidget

setmetatable(RangeWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function RangeWidget:text(text)
    self.state["tex"] = text
    return self
end

function RangeWidget:value(value)
    self.state["val"] = value
    return self
end

function RangeWidget:unit(unit)
    self.state["uni"] = unit
    return self
end

function RangeWidget:icon(icon)
    self.state["ico"] = icon
    return self
end

function RangeWidget:color(color)
    self.state["clr"] = color
    return self
end

function RangeWidget:max(num)
    self.state["max"] = num
    return self
end

-- RGB组件
RGBWidget = {}
RGBWidget.__index = RGBWidget

setmetatable(RGBWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function RGBWidget:text(text)
    self.state["tex"] = text
    return self
end

function RGBWidget:brightness(brightness)
    self.state[3] = brightness
    return self
end

local function to_rgb(color_hex)
    local r = tostring(tonumber(string.format("0x%06X", string.sub(color_hex, 2, 4)), 16))
    local g = tostring(tonumber(string.format("0x%06X", string.sub(color_hex, 4, 6)), 16))
    local b = tostring(tonumber(string.format("0x%06X", string.sub(color_hex, 6, 8)), 16))

    return {r, g, b}
end

function RGBWidget:color(color)
    if type(color) == "string" and string.sub(color, 1,1) == "#" then
        self.state = to_rgb(color)
    elseif #color == 3 or #color == 4 then
        self.state = color
    end
    return self
end

-- Image组件
ImageWidget = {}
ImageWidget.__index = ImageWidget

setmetatable(ImageWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function ImageWidget:show(img)
    self.state["img"] = img
    return self
end

-- Video组件
VideoWidget = {}
VideoWidget.__index = VideoWidget

setmetatable(VideoWidget, {
    __index = BlinkerWidgets,
    __call = function (cls, ...)
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end
})

function VideoWidget:url(addr)
    self.state["url"] = addr
    return self
end

function VideoWidget:autoplay(swi)
    self.state["auto"] = swi
    return self
end
