--PHONE APP MINE--

local SERVER_PORT = 420
local PHONE_PORT = 69

-- Auto-detect modem on either side
local modem
for _, side in ipairs({"left", "right", "front", "back", "top", "bottom"}) do
    if peripheral.getType(side) == "modem" then
        modem = peripheral.wrap(side)
        break
    end
end

if not modem then
    error("No modem found on any side")
end
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
