function tohex(byte)
    -- convert base10 byte to hex string
    local hexByte = string.format("%02X", byte)
    return hexByte
  end

function dump_i16(n)
    assert (-0x8000 <= n and n < 0x8000)
    local b1 = (n >> 8) & ~(-1<<(64-8))
    local b2 = (n >> 0) & 0xff
    return b1, b2
end

function read_i16(b1, b2)
    assert (0 <= b1 and b1 <= 0xff)
    assert (0 <= b2 and b2 <= 0xff)
    local mask = (1 << 15)
    local res  = (b1 << 8) | (b2 << 0)
    return (res ~ mask) - mask
end

h, l = dump_i16(500)
print(h, l)
print(read_i16(h, l))
-- print(tohex(h))
-- print(tohex(l))