
-- ftp put /home/user/projects/apm_lua/scripts/lib/custom_tools.lua APM/scripts/custom_tools.lua
-- ftp put /home/user/projects/apm_lua/scripts/simple_loop.lua APM/scripts/simple_loop.lua
-- ftp list APM/scripts
-- ftp list APM/scripts/lib
-- ftp rm APM/scripts/hello_lua.lua
-- ftp rm APM/scripts/custom_tools.lua

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

DriveMsg = {Throttle=0, Steer=0, Brake=0, State=0}

local ENGINE_STATE = 1<<0
local REAR_RAMP_OPEN = 1<<1
local REAR_RAMP_CLOSE = 1<<2


function DriveMsg:new()
    setmetatable({}, DriveMsg)
    return self
end

function DriveMsg:get_EngingState()
    return self.Commands & 1<<0
end

function DriveMsg:rear_ramp_open_state()
    return (self.Commands & REAR_RAMP_OPEN) == REAR_RAMP_OPEN
end

function DriveMsg:is_RearRampClose()
    return (self.Commands & REAR_RAMP_CLOSE) == REAR_RAMP_CLOSE
end

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

function DriveMsg:toString()
    message_str = string.format("%s %s %s %i %s %s"
        , self.Throttle
        , self.Steer
        , self.Brake
        , self:get_EngingState()
        , tostring(self:rear_ramp_open_state())
        , tostring(self:is_RearRampClose())
    )
    return message_str
end

message = DriveMsg:new()
message.Throttle = 500
message:set_EngingState(true)
-- message:set_EngingState(false)
message:set_RearRampOpen(true)



function update() -- periodic function that will be called
    -- if ahrs:healthy() then
    --     gcs:send_text(0, "hello lua")
    -- end

    gcs:send_text(0, message:toString())

    -- rescheduler the loop
    return update, 1000
end

-- Run immdeiately before rescheduler
return update()