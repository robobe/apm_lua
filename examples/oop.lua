-- lua isn't oop programing language

Animal = {name="", color="black"}

function Animal:new(name)
    setmetatable({}, Animal)
    self.name = name

    return self
end

function Animal:toString()
    animal_str = string.format("%s %s", self.name, self.color)
    return animal_str
end

spot = Animal:new(10)
print(spot.color)
print(spot:toString())
