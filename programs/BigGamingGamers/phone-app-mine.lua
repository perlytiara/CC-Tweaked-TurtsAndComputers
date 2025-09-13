--PHONE APP MINE--

local SERVER_PORT = 420
local PHONE_PORT = 69

local modem = peripheral.wrap("back")
---@class Vec3
---@field x number
---@field y number
---@field z number
local size = { x = 0, y = 0, z = 0 }

if (#arg == 3) then
    local ax = tonumber(arg[1])
    local ay = tonumber(arg[2])
    local az = tonumber(arg[3])
    if not (ax and ay and az) then
        print("Invalid size numbers")
        os.exit()
    end
    ---@cast ax number
    ---@cast ay number
    ---@cast az number
    size.x = ax
    size.y = ay
    size.z = az
else
    print("NO SIZE GIVEN")
    os.exit(1)
end

local gx, gy, gz = gps.locate()
if not gx then
    print("GPS not available")
    os.exit(1)
end
local target = vector.new(gx, gy, gz)
local payloadMessage = string.format("%d %d %d %d %d %d %d",
    target.x, target.y - 1, target.z,
    size.x, size.y, size.z,
    1
)

print(string.format("Targetting %d %d %d", target.x, target.y, target.z))
modem.transmit(SERVER_PORT, PHONE_PORT, payloadMessage)
