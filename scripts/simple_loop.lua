local number = math.random()

function update() -- periodic function that will be called
    if ahrs:healthy() then
        gcs:send_text(0, "hello lua")
    end
    gcs:send_text(0, "hello lua")
    gcs:send_named_float("lua float", number)
    number = number + math.random()

    -- rescheduler the loop
    return update, 1000
end

-- Run immdeiately before rescheduler
return update()