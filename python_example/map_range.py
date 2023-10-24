def translate(value, leftMin, leftMax, rightMin, rightMax):
    # Figure out how 'wide' each range is
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin

    # Convert the left range into a 0-1 range (float)
    valueScaled = float(value - leftMin) / float(leftSpan)

    # Convert the 0-1 range into a value in the right range.
    return rightMin + (valueScaled * rightSpan)

print(translate(500, 0, 1000, 0, 10))
print(translate(0, 0, 1000, 0, 10))
print(translate(1000, 0, 1000, 0, 10))
print(translate(500, 0, 1000, 0, -10))
print(translate(0, 0, 1000, 0, -10))
print(translate(1000, 0, 1000, 0, -10))
print(translate(1000, 0, 1000, -10, 0))