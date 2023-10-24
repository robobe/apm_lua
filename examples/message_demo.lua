DriveMsg = {Throttle=0, Steer=0, Brake=0, State=0}

local ENGINE_STATE = 1<<0
local REAR_RAMP_OPEN = 1<<1
local REAR_RAMP_CLOSE = 1<<2
local HORN = 1<<3
local SMOKE = 1<<4
local LIGHT_LOW_BEAM = 1<<5
local LIGHT_HIGH_BEAM = 1<<6
local LIGHT_CAT_EYES = 1<<7

-- region helper functions
function tohex(byte)
    -- convert base10 byte to hex string
    local hexByte = string.format("%02X", byte)
    return hexByte
  end

function to_i16(n)
    assert (-0x8000 <= n and n < 0x8000)
    local b1 = (n >> 8) & ~(-1<<(64-8))
    local b2 = (n >> 0) & 0xff
    return b1, b2
end

function from_i16(b1, b2)
    assert (0 <= b1 and b1 <= 0xff)
    assert (0 <= b2 and b2 <= 0xff)
    local mask = (1 << 15)
    local res  = (b1 << 8) | (b2 << 0)
    return (res ~ mask) - mask
end
-- endregion

DriveMsg = {Throttle=0, Steer=0, Break=0, Commands=0}

-- region drive message
function DriveMsg:new(throttle, horn)
    setmetatable({}, DriveMsg)
    self.Throttle = throttle or 0
    self.Commands = horn and self.Commands | HORN or self.Commands & ~HORN
    return self
end

-- region state
function DriveMsg:get_EngingState()
    return (self.Commands & ENGINE_STATE) == ENGINE_STATE
end

function DriveMsg:is_RearRampOpen()
    return (self.Commands & REAR_RAMP_OPEN) == REAR_RAMP_OPEN
end

function DriveMsg:is_RearRampClose()
    return (self.Commands & REAR_RAMP_CLOSE) == REAR_RAMP_CLOSE
end

function DriveMsg:isHorn()
    return (self.Commands & HORN) == HORN
end

function DriveMsg:smoke()
    return (self.Commands & SMOKE) == SMOKE
end
-- endregion state

function DriveMsg:set_RearRampClose(value)
    if value then
        self.Commands = self.Commands | REAR_RAMP_CLOSE
    else
        self.Commands = self.Commands & ~REAR_RAMP_CLOSE
    end
end

function DriveMsg:set_RearRampOpen(value)
    if value then
        self.Commands = self.Commands | REAR_RAMP_OPEN
    else
        self.Commands = self.Commands & ~REAR_RAMP_OPEN
    end
end

function DriveMsg:set_EngingState(value)
    if value then
        self.Commands = self.Commands | ENGINE_STATE
    else
        self.Commands = self.Commands & ~ENGINE_STATE
    end
end

function DriveMsg:set_Smoke(value)
    if value then
        self.Commands = self.Commands | SMOKE
    else
        self.Commands = self.Commands & ~SMOKE
    end
end

-- region
function DriveMsg:toString()
    message_str = string.format([[
    Throotle: %s
    Steer: %s
    Break: %s
    Engine: %s
    RampOpen %s
    RampClode %s 
    Horn: %s
    Smoke: %s
    ]]
        , self.Throttle
        , self.Steer
        , self.Brake
        , tostring(self:get_EngingState())
        , tostring(self:is_RearRampOpen())
        , tostring(self:is_RearRampClose())
        , tostring(self:isHorn())
        , tostring(self:smoke())
    )
    return message_str
end

function DriveMsg:toBytes()
    raw = {0, 0, 0, 0, 0, 0, 0, 0}
    raw[1], raw[2] = to_i16(self.Throttle)
    return raw
end

function DriveMsg:fromBytes(raw)
    self.Throttle = from_i16(raw[1], raw[2])
    print(self.Throttle)
end
-- endregion

-- endregion message

message = DriveMsg:new()
message:fromBytes({1, 244, 0})
message:set_EngingState(true)
-- message:set_EngingState(false)
message:set_RearRampOpen(true)
-- message:set_RearRampOpen(false)
-- message:set_RearRampClose(true)
print(type(message:is_RearRampClose()))
print(message:toString())
for i, b in pairs(message:toBytes()) do
    print(i, b)
end
