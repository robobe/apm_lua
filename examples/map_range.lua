
function translate(value, leftMin, leftMax, rightMin, rightMax)
    -- Figure out how 'wide' each range is
    value = math.max(value, leftMin)
    value = math.min(value, leftMax)
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin
    -- Convert the left range into a 0-1 range (float)
    valueScaled = (value - leftMin) / (leftSpan)

    -- Convert the 0-1 range into a value in the right range.
    result =  rightMin + (valueScaled * rightSpan)
    
    return math.floor(result)
end

-- print(translate(500, 0, 1000, 0, 10))
-- print(translate(0, 0, 1000, 0, 10))
-- print(translate(1000, 0, 1000, 0, 10))
-- print(translate(500, 0, 1000, 0, -10))
-- print(translate(0, 0, 1000, 0, -10))
-- print(translate(1000, 0, 1000, 0, -10))
-- print(translate(1750, 1500, 2000, 0, 500))
print(translate(1751, 1500, 2000, 500, 0))

