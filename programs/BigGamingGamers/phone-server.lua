--PHONE  SERVER--

local SERVER_PORT = 420
local CLIENT_PORT = 0
local SLOT_COUNT = 16


local segmentation = 5
if (#arg == 1) then
    segmentation = tonumber(arg[1])
elseif (#arg == 0) then
    print(string.format("No segmentation size selected, defaulting to %d", segmentation))
else
    print('Too many args given...')
    exit(1)
end


local modem = peripheral.wrap("left")
modem.open(SERVER_PORT)

local target = vector.new()
local size = vector.new()
local finish = vector.new()

-- I STOLE --
function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function parseParams(data)
    coords = {}
    params = split(data, " ")
    
    coords[1] = vector.new(params[1], params[2], params[3])
    coords[2] = vector.new(params[4], params[5], params[6])

    return (coords)
end

function getItemIndex(itemName)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == itemName) then
                return slot
            end
        end
    end
end

function checkFuel()
    turtle.select(1)
    
    if(turtle.getFuelLevel() < 50) then
        print("Attempting Refuel...")
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel(1)) then
                return true
            end
        end
        return false
    else
        return true
    end
end

function deployFuelChest()
    if (not checkFuel()) then
        print("SERVER NEEDS FUEL...")
        exit(1)
    end
    turtle.select(getItemIndex("enderstorage:ender_storage"))
    turtle.up()
    turtle.place()
    turtle.down()
end


function deploy(startCoords, quarySize, endCoords, options)
    --Place turtle from inventory
    turtle.select(getItemIndex("computercraft:turtle_expanded"))
    while(turtle.detect()) do
        os.sleep(0.3)
    end

    --Place and turn on turtle
    turtle.place()
    peripheral.call("front", "turnOn")
    
    
    --Wait for client to send ping
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    if(msg ~= "CLIENT_DEPLOYED") then
        print("No client deploy message, exitting...")
        os.exit()
    end

    
    if(options["withStorage"]) then
        --Set up ender chest
        if (not checkFuel()) then
            print("SERVER NEEDS FUEL...")
            exit(1)
        end
        turtle.select(getItemIndex("enderstorage:ender_storage"))
        turtle.up()
        turtle.place()
        turtle.down()
    end
    
    deployFuelChest()
    local storageBit = options["withStorage"] and 1 or 0

    -- Client is deployed
    modem.transmit(CLIENT_PORT,
        SERVER_PORT,
        string.format("%d %d %d %d %d %d %d %d %d %d", 
        startCoords.x, startCoords.y, startCoords.z,
        quarySize.x, quarySize.y, quarySize.z,
        endCoords.x, endCoords.y, endCoords.z,
        storageBit
    ))
end



-- Return array of arbitrary size for each bot placement
function getPositioningTable(x, z, segmaentationSize)
    local xRemainder = x % segmaentationSize
    local zRemainder = z % segmaentationSize

    local xMain = x - xRemainder
    local zMain = z - zRemainder

    xRemainder = (xRemainder == 0 and segmaentationSize or xRemainder)
    zRemainder = (zRemainder == 0 and segmaentationSize or zRemainder)

    local positions = {}

    for zi = 0, z - 1 , segmaentationSize do
        for xi = 0, x - 1, segmaentationSize do
            
            local dims = {xi, zi, segmaentationSize, segmaentationSize}
            if(xi >= x - segmaentationSize and xi <= x - 1 ) then
                dims = {xi, zi, xRemainder, segmaentationSize}
            end
            
            if(zi >= z - segmaentationSize and zi <= z - 1 ) then
                dims = {xi, zi, segmaentationSize, zRemainder}
            end
            
            table.insert(positions, dims)
        end
    end
    
    return table.pack(positions, xRemainder, zRemainder)
end

while (true) do
    -- Wait for phone
    print("Waiting for target signal...")
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")

    -- Parse out coordinates and options
    local args = split(msg, " ")
    local withStorage = args[#args]
    withStorage = withStorage == "1" and true or false
    data = parseParams(msg)
    options = {}
    options["withStorage"] = True

    target = data[1]
    size = data[2]

    finish = vector.new(gps.locate())
    finish.y = finish.y + 1
    print(string.format( "RECEIVED QUARY REQUEST AT: %d %d %d", target.x, target.y, target.z))

    tab, xDf, zDf = table.unpack(getPositioningTable(size.x, size.z, segmentation))

    print(string.format("Deploying %d bots...", #tab))
    for i = 1, #tab, 1 do
        xOffset, zOffset, width, height = table.unpack(tab[i])
        local offsetTarget = vector.new(target.x + xOffset, target.y, target.z + zOffset)
        local sclaedSize = vector.new(width, size.y, height)

        deploy(offsetTarget, sclaedSize, finish, options)
        os.sleep(1)
        print(string.format( "Deploying to;  %d %d %d    %d %d",  target.x + xOffset, target.y, target.z + zOffset, sclaedSize.x, sclaedSize.z))
    end

    -- All bots deployed, wait for last bot finished signal
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    turtle.digUp()

end

