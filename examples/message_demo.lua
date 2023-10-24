-- region consts
local ENGINE_STATE = 1<<0
local REAR_RAMP_OPEN = 1<<1
local REAR_RAMP_CLOSE = 1<<2
local HORN = 1<<3
local SMOKE = 1<<4
local LIGHT_LOW_BEAM = 1<<5
local LIGHT_HIGH_BEAM = 1<<6
local LIGHT_CAT_EYES = 1<<7

local INDEX_THROTLE_HIGH = 1
local INDEX_THROTLE_LOW = 2
local INDEX_STEER_HIGH = 3
local INDEX_STEER_LOW = 4
local INDEX_BRAKE = 5
local INDEX_STATUS = 6

local BIT_MASK = 0x01
local NIBBLE_MASK = 0x03
local STATUS_REAR_RAMP_INDEX = 2<<1
local STATUS_HORN_INDEX = 4<<1
-- endregion consts

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
StatusMsg = {Throttle=0, Steer=0, Break=0, Status=0}

-- region status message
function StatusMsg:new()
    setmetatable({}, StatusMsg)
    return self
end

function StatusMsg:enging_state()
    state_str = {"off","on","","error"} --TODO: move to global
    state = (self.Status >> 0) & 0x03
    return state, state_str[state+1]
end

function StatusMsg:rear_ramp_state()
    local state_str = {"close", "open", "mid-way", "error"} --TODO: move to global
    local state = (self.Status >> STATUS_REAR_RAMP_INDEX) & NIBBLE_MASK
    print("state --" .. state)
    return state, state_str[state+1]
end

function StatusMsg:horn()
    
    local state = (self.Status >> STATUS_HORN_INDEX) & BIT_MASK
    return state
end

function StatusMsg:smoke()
    local state = (self.Status >> 5) & BIT_MASK
    return state
end
function StatusMsg:low_beam()
    local state = (self.Status >> 6) & BIT_MASK
    return state
end
function StatusMsg:high_beam()
    local state = (self.Status >> 7) & BIT_MASK
    return state
end
function StatusMsg:cay_eyes()
    local state = (self.Status >> 8) & BIT_MASK
    return state
end
function StatusMsg:toString()
    -- RampOpen %s
    -- RampClode %s 
    -- Horn: %s
    -- Smoke: %s
    -- , tostring(self:is_RearRampOpen())
        -- , tostring(self:is_RearRampClose())
        -- , tostring(self:isHorn())
        -- , tostring(self:smoke())
    _, rear_ramp_state = self:rear_ramp_state()
    _, engine_state = self:enging_state()

    message_str = string.format([[
    Throotle: %s
    Steer: %s
    Break: %s
    Engine: %s
    Rear Ramp: %s
    Horn: %i
    Smoke: %i
    Low beam: %i
    High beam: %i
    Cat eyes: %i
    ]]
        , self.Throttle
        , self.Steer
        , self.Brake
        , engine_state
        , rear_ramp_state
        , self:horn()
        , self:smoke()
        , self:low_beam()
        , self:high_beam()
        , self:cay_eyes()
    )
    return message_str
end



function StatusMsg:fromBytes(raw)
    self.Throttle = from_i16(raw[INDEX_THROTLE_HIGH], raw[INDEX_THROTLE_LOW])
    self.Steer = from_i16(raw[INDEX_STEER_HIGH], raw[INDEX_STEER_LOW])
    self.Break = raw[INDEX_BRAKE]
    self.Status = raw[INDEX_STATUS]
end

-- endregion status message

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

function DriveMsg:LIGHT_LOW_BEAM()
    return (self.Commands & LIGHT_LOW_BEAM) == LIGHT_LOW_BEAM
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

-- region light_low_beam
function DriveMsg:light_low_beam_on()
    self.Commands = self.Commands | LIGHT_LOW_BEAM
end

function DriveMsg:light_low_beam_off()
    self.Commands = self.Commands & ~LIGHT_LOW_BEAM
end
-- endregion light_low_beam

-- region light high beam
function DriveMsg:light_high_beam_on()
    self.Commands = self.Commands | LIGHT_HIGH_BEAM
end

function DriveMsg:light_high_beam_off()
    self.Commands = self.Commands & ~LIGHT_HIGH_BEAM
end
-- endregion light high beam

-- region light_cay_eyes
function DriveMsg:light_cay_eyes_on()
    self.Commands = self.Commands | LIGHT_CAT_EYES
end

function DriveMsg:light_cay_eyes_off()
    self.Commands = self.Commands & ~LIGHT_CAT_EYES
end
-- endregion light_cay_eyes

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
end
-- endregion

-- endregion message

status_message = StatusMsg:new()
status_message:fromBytes({1, 244, 0, 0, 0, 0x091c})
print("status:" .. status_message.Status)
print(status_message:toString())
print("-----------------")
-- message = DriveMsg:new()
-- message:fromBytes({1, 244, 0})
-- message:set_EngingState(true)
-- -- message:set_EngingState(false)
-- message:set_RearRampOpen(true)
-- -- message:set_RearRampOpen(false)
-- -- message:set_RearRampClose(true)
-- print(type(message:is_RearRampClose()))
-- print(message:toString())
-- for i, b in pairs(message:toBytes()) do
--     print(i, b)
-- end


