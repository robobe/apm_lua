file = io.open("test.txt", "w+")
file:write("first line\n")
file:write("second line\n")

file:seek("set", 0)

print(file:read("*a"))

file:close()
