-- This script is an example of writing to CAN bus

-- Load CAN driver, using the scripting protocol and with a buffer size of 5
local buf_len = uint32_t(20)
local driver = CAN:get_device(buf_len)

function show_frame(dnum, frame)
  gcs:send_text(0,string.format("CAN[%u] msg from " .. tostring(frame:id()) .. ": %i, %i, %i, %i, %i, %i, %i, %i", dnum, frame:data(0), frame:data(1), frame:data(2), frame:data(3), frame:data(4), frame:data(5), frame:data(6), frame:data(7)))
end

function update()

  -- send UAVCAN Light command
  -- uavcan.equipment.indication.LightsCommand
  -- note that as we don't do dynamic node allocation, the target light device must have a static node ID
  if driver then
    frame = driver:read_frame()
    if frame then
       show_frame(1, frame)
    end
 end

  msg = CANFrame()

  -- extended frame, priority 30, message ID 1081 and node ID 11
  -- lua cannot handle numbers so large, so we have to use uint32_t userdata
  msg:id( (uint32_t(1) << 31) | (uint32_t(30) << 24) | (uint32_t(1081) << 8) | uint32_t(11) )

  msg:data(0,0) -- set light_id = 0


  -- first is made up of 5 bits red and 3 bits of green
  msg:data(1, 1)
  msg:data(2, 2)
  msg:data(3, 3)
  msg:data(4, 4)
  msg:data(5, 5)
  msg:data(6, 0xfe)
  msg:data(7, 0xff)
  -- msg:data(8, 10)
  -- msg:data(9, 1)
  -- msg:data(10, 2)
  -- msg:data(11, 3)
  -- msg:data(12, 4)
  -- msg:data(13, 5)
  -- msg:data(14, 6)
  -- msg:data(15, 7)
  -- msg:data(16, 8)



  -- sending 4 bytes of data
  msg:dlc(8)

  -- write the frame with a 10000us timeout
  driver:write_frame(msg, 10000)

  

  return update, 100

end

return update()