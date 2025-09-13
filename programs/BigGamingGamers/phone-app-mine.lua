--PHONE APP MINE--

local SERVER_PORT = 420
local PHONE_PORT = 69

modem = peripheral.wrap("back")
local size = vector.new()

if (#arg == 3) then
    size.x = tonumber(arg[1])
    size.y = tonumber(arg[2])
    size.z = tonumber(arg[3])
else
    print("NO SIZE GIVEN")
    os.exit(1)
end

local target = vector.new(gps.locate())
local payloadMessage = string.format("%d %d %d %d %d %d %d",
    target.x, target.y - 1, target.z,
    size.x, size.y, size.z,
    1
)

print(string.format("Targetting %d %d %d", target.x, target.y, target.z))
modem.transmit(SERVER_PORT, PHONE_PORT, payloadMessage)
