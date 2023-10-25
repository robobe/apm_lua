-- region consts
local THROTTEL_COMMAD_SAFE_STATE = 0
local BRAK_COMMAND_SAFE_STATE = 255

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
local INDEX_CMD = 6

local BIT_MASK = 0x01   -- 0b00000001
local NIBBLE_MASK = 0x03 -- 0b00000011
local STATUS_FLAG_REAR_RAMP_INDEX = 2
local STATUS_FLAG_HORN_INDEX = 4
local STATUS_FLAG_SMOKE_INDEX = 5
local STATUS_FLAG_LOW_BEAM_INDEX = 6
local STATUS_FLAG_HIGH_BEAM_INDEX = 7
local STATUS_FLAG_CAT_EYE_INDEX = 8
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
    local state = (self.Status >> STATUS_FLAG_REAR_RAMP_INDEX) & NIBBLE_MASK
    return state, state_str[state+1]
end

function StatusMsg:horn()
    
    local state = (self.Status >> STATUS_FLAG_HORN_INDEX) & BIT_MASK
    return state
end

function StatusMsg:smoke()
    local state = (self.Status >> STATUS_FLAG_SMOKE_INDEX) & BIT_MASK
    return state
end
function StatusMsg:low_beam()
    local state = (self.Status >> STATUS_FLAG_LOW_BEAM_INDEX) & BIT_MASK
    return state
end
function StatusMsg:high_beam()
    local state = (self.Status >> STATUS_FLAG_HIGH_BEAM_INDEX) & BIT_MASK
    return state
end
function StatusMsg:cay_eyes()
    local state = (self.Status >> STATUS_FLAG_CAT_EYE_INDEX) & BIT_MASK
    return state
end
function StatusMsg:toString()
    --[[
    return status message as string
    --]]
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
    --[[
    convert 8byte message to ststus message
    --]]
    self.Throttle = from_i16(raw[INDEX_THROTLE_HIGH], raw[INDEX_THROTLE_LOW])
    self.Steer = from_i16(raw[INDEX_STEER_HIGH], raw[INDEX_STEER_LOW])
    self.Break = raw[INDEX_BRAKE]
    self.Status = raw[INDEX_STATUS]
end

-- endregion status message

-- region drive message
function DriveMsg:new()
    setmetatable({}, DriveMsg)
    self.Throttle = THROTTEL_COMMAD_SAFE_STATE
    self.Break = BRAK_COMMAND_SAFE_STATE
    self:enging_off()
    return self
end

-- region commands

-- region engine cmd
function DriveMsg:engine_state()
    return (self.Commands & ENGINE_STATE) == ENGINE_STATE
end

function DriveMsg:engine_on()
    self.Commands = self.Commands | ENGINE_STATE
end

function DriveMsg:enging_off()
    self.Commands = self.Commands & ~ENGINE_STATE
end
-- endregion engine cmd

-- region open rear ramp
function DriveMsg:rear_ramp_open_state()
    return (self.Commands & REAR_RAMP_OPEN) == REAR_RAMP_OPEN
end

function DriveMsg:rear_ramp_open_on()
    if not self:rear_ramp_close_state() then
        self.Commands = self.Commands | REAR_RAMP_OPEN
    end
end

function DriveMsg:rear_ramp_open_off()
    self.Commands = self.Commands & ~REAR_RAMP_OPEN
end
-- endregion open reae ramp

-- region rear ramp close
function DriveMsg:rear_ramp_close_state()
    return (self.Commands & REAR_RAMP_CLOSE) == REAR_RAMP_CLOSE
end

function DriveMsg:rear_ramp_close_on()
    if not self:rear_ramp_open_state() then
        self.Commands = self.Commands | REAR_RAMP_CLOSE
    end
end 

function DriveMsg:rear_ramp_close_off()
    self.Commands = self.Commands & ~REAR_RAMP_CLOSE
end
-- endregion rear ramp close

-- region horn
function DriveMsg:horn_state()
    return (self.Commands & HORN) == HORN
end

function DriveMsg:horn_on()
    self.Commands = self.Commands | HORN
end 

function DriveMsg:horn_off()
    self.Commands = self.Commands & ~HORN
end
-- endregion rear ramp close

-- region smoke
function DriveMsg:smoke_status()
    return (self.Commands & SMOKE) == SMOKE
end

function DriveMsg:smoke_on()
    self.Commands = self.Commands | SMOKE
end
    
function DriveMsg:smoke_off()
    self.Commands = self.Commands & ~SMOKE
end
-- endregion smoke

-- region light_low_beam
function DriveMsg:light_low_beam_status()
    return (self.Commands & LIGHT_LOW_BEAM) == LIGHT_LOW_BEAM
end

function DriveMsg:light_low_beam_on()
    self.Commands = self.Commands | LIGHT_LOW_BEAM
end

function DriveMsg:light_low_beam_off()
    self.Commands = self.Commands & ~LIGHT_LOW_BEAM
end
-- endregion light_low_beam

-- region light high beam
function DriveMsg:light_high_beam_status()
    return (self.Commands & LIGHT_HIGH_BEAM) == LIGHT_HIGH_BEAM
end

function DriveMsg:light_high_beam_on()
    self.Commands = self.Commands | LIGHT_HIGH_BEAM
end

function DriveMsg:light_high_beam_off()
    self.Commands = self.Commands & ~LIGHT_HIGH_BEAM
end
-- endregion light high beam

-- region light_cay_eyes
function DriveMsg:light_cat_eyes_status()
    return (self.Commands & LIGHT_CAT_EYES) == LIGHT_CAT_EYES
end
function DriveMsg:light_cay_eyes_on()
    self.Commands = self.Commands | LIGHT_CAT_EYES
end

function DriveMsg:light_cay_eyes_off()
    self.Commands = self.Commands & ~LIGHT_CAT_EYES
end
-- endregion light_cay_eyes

-- endregion commands

-- region

function DriveMsg:toString()
    message_str = string.format([[
    Throotle: %s
    Steer: %s
    Break: %s
    Engine: %s
    Ramp open %s
    Ramp close %s 
    Horn: %s
    Smoke: %s
    Low beam: %s
    High beam: %s
    Cat eye: %s
    ]]
        , self.Throttle
        , self.Steer
        , self.Break
        , tostring(self:engine_state())
        , tostring(self:rear_ramp_open_state())
        , tostring(self:rear_ramp_close_state())
        , tostring(self:horn_state())
        , tostring(self:smoke_status())
        , tostring(self:light_low_beam_status())
        , tostring(self:light_high_beam_status())
        , tostring(self:light_cat_eyes_status())
    )
    return message_str
end

function DriveMsg:toBytes()
    raw = {0, 0, 0, 0, 0, 0, 0, 0}
    raw[INDEX_THROTLE_HIGH], raw[INDEX_THROTLE_LOW] = to_i16(self.Throttle)
    raw[INDEX_STEER_HIGH], raw[INDEX_STEER_LOW] = to_i16(self.Steer)
    raw[INDEX_BRAKE] = self.Break
    raw[INDEX_CMD] = self.Commands
    return raw
end

-- endregion

-- endregion message

status_message = StatusMsg:new()
status_message:fromBytes({1, 244, 0, 0, 0, 0x091c})
print("status:" .. status_message.Status)
print(status_message:toString())
print("-----------------")
drive_cmd_msg = DriveMsg:new()
drive_cmd_msg:engine_on()
drive_cmd_msg:rear_ramp_open_on()
drive_cmd_msg:rear_ramp_close_on()
print(drive_cmd_msg:toString())


