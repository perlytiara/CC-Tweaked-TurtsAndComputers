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
    error('Too many args given...', 0)
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

function selectFirstAvailable(itemNames)
    for i = 1, #itemNames, 1 do
        local idx = getItemIndex(itemNames[i])
        if idx ~= nil then
            turtle.select(idx)
            return true
        end
    end
    return false
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
        error('Server out of fuel', 0)
    end
    local idx = getItemIndex("enderstorage:ender_storage")
    if idx ~= nil then
        turtle.select(idx)
        turtle.up()
        turtle.place()
        turtle.down()
    else
        print("WARN: EnderStorage not found; skipping fuel chest deploy")
    end
end

-- Helper function to check if a turtle item has a specific upgrade (e.g., modem or tool)
function hasUpgrade(itemDetail, upgradeType)
    if not itemDetail or not itemDetail.nbt or not itemDetail.nbt.tag or not itemDetail.nbt.tag.upgrades then
        print("No valid NBT or upgrades data found for item.")
        return false
    end
    local upgrades = itemDetail.nbt.tag.upgrades
    for _, upgrade in ipairs(upgrades) do
        if type(upgrade) == "table" and upgrade.id then
            print("Found upgrade: " .. (upgrade.id or "unknown"))
            if upgradeType == "mining_tool" then
                -- Broaden check for mining tools (CC: Tweaked might use custom IDs)
                if string.find(upgrade.id, "pickaxe") or string.find(upgrade.id, "drill") or string.find(upgrade.id, "mining") then
                    return true
                end
            elseif upgradeType == "modem" then
                -- Check for any modem, prefer ender if present
                if string.find(upgrade.id, "modem") then
                    if string.find(upgrade.id, "ender") then
                        print("Detected Ender Modem (unlimited range, cross-dimension).")
                    else
                        print("Detected Wireless Modem (limited range, same dimension).")
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- Function to find and select a mining turtle from slot 1 with required upgrades
function selectMiningTurtle()
    local item = turtle.getItemDetail(1)
    if item and (item.name == "computercraft:turtle_advanced" or item.name == "computercraft:turtle_normal") then
        local hasMiningTool = hasUpgrade(item, "mining_tool")
        local hasModem = hasUpgrade(item, "modem")
        if hasMiningTool and hasModem then
            turtle.select(1)
            print("Selected mining turtle from slot 1: " .. item.name .. " with mining tool and modem.")
            return true
        else
            print("Slot 1 turtle missing mining tool or modem. Current upgrades: " .. (item.nbt and item.nbt.tag and #item.nbt.tag.upgrades or "0") .. " upgrades.")
        end
    else
        print("Slot 1 does not contain a valid mining turtle (computercraft:turtle_*).")
    end
    return false
end

-- Function to find and select a chunky turtle from slot 2 with required upgrades
function selectChunkyTurtle()
    local item = turtle.getItemDetail(2)
    if item and item.name == "advancedperipherals:chunky_turtle" then
        local hasModem = hasUpgrade(item, "modem")
        if hasModem then
            turtle.select(2)
            print("Selected chunky turtle from slot 2: advancedperipherals:chunky_turtle with modem.")
            return true
        else
            print("Slot 2 chunky turtle missing modem.")
        end
    else
        print("Slot 2 does not contain a valid chunky turtle (advancedperipherals:chunky_turtle).")
    end
    return false
end


function deployPair(startCoords, quarySize, endCoords, options)
    -- Ensure fuel before starting
    if (not checkFuel()) then
        print("SERVER NEEDS FUEL...")
        error('Server out of fuel', 0)
    end

    -- Select and place mining turtle from slot 1 (pre-checked for upgrades)
    if not selectMiningTurtle() then
        print("ERROR: No valid mining turtle found in slot 1 (must be computercraft:turtle_* with mining tool and modem).")
        error('Missing valid mining turtle in slot 1', 0)
    end
    while(turtle.detect()) do
        os.sleep(0.3)
    end

    --Place and turn on mining turtle
    turtle.place()
    peripheral.call("front", "turnOn")
    
    --Wait for mining client to send ping
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    if(msg ~= "CLIENT_DEPLOYED") then
        print("No mining client deploy message, exiting...")
        error('Mining client deploy handshake failed', 0)
    end

    -- Now place chunky turtle behind the server (to tail the mining turtle)
    -- Turn around to face backward
    turtle.turnLeft()
    turtle.turnLeft()
    os.sleep(0.5)  -- Brief pause for stability
    
    -- Ensure space behind is clear
    while(turtle.detect()) do
        -- If blocked, try to dig (assuming server has dig capability)
        if not turtle.dig() then
            print("Cannot clear space behind for chunky turtle!")
            error('Failed to place chunky turtle', 0)
        end
        os.sleep(0.3)
    end
    
    -- Select chunky turtle from slot 2 (pre-checked)
    if not selectChunkyTurtle() then
        print("ERROR: No valid chunky turtle found in slot 2 (must be advancedperipherals:chunky_turtle with modem).")
        error('Missing valid chunky turtle in slot 2', 0)
    end
    
    turtle.place()
    peripheral.call("front", "turnOn")
    
    --Wait for chunky client to send ping
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    if(msg ~= "CLIENT_DEPLOYED") then
        print("No chunky client deploy message, exiting...")
        error('Chunky client deploy handshake failed', 0)
    end
    
    -- Turn server back to original orientation (face forward again)
    turtle.turnLeft()
    turtle.turnLeft()
    
    if(options["withStorage"]) then
        --Set up ender chest for storage (place above mining turtle position)
        if (not checkFuel()) then
            print("SERVER NEEDS FUEL...")
            error('Server out of fuel', 0)
        end
        local idx = getItemIndex("enderstorage:ender_storage")
        if idx ~= nil then
            -- Move forward to align with mining turtle if needed, but assume positioned
            turtle.up()
            turtle.place()
            turtle.down()
        else
            print("WARN: EnderStorage not found; skipping storage chest deploy")
        end
    end
    
    deployFuelChest()
    local storageBit = options["withStorage"] and 1 or 0

    -- Send deployment message to both turtles (broadcast; clients should handle pairing logic)
    modem.transmit(CLIENT_PORT,
        SERVER_PORT,
        string.format("%d %d %d %d %d %d %d %d %d %d %d", 
        startCoords.x, startCoords.y, startCoords.z,
        quarySize.x, quarySize.y, quarySize.z,
        endCoords.x, endCoords.y, endCoords.z,
        storageBit,
        1  -- Pair flag: 1 for mining, 2 for chunky (clients can filter or use separate channels if needed)
    ))
    
    print("Pair deployed: Mining at front, Chunky tailing behind.")
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
    options["withStorage"] = withStorage

    target = data[1]
    size = data[2]

    finish = vector.new(gps.locate())
    finish.y = finish.y + 1
    print(string.format( "RECEIVED QUARY REQUEST AT: %d %d %d", target.x, target.y, target.z))

    tab, xDf, zDf = table.unpack(getPositioningTable(size.x, size.z, segmentation))

    print(string.format("Deploying %d pairs (2 turtles each)...", #tab))
    for i = 1, #tab, 1 do
        xOffset, zOffset, width, height = table.unpack(tab[i])
        local offsetTarget = vector.new(target.x + xOffset, target.y, target.z + zOffset)
        local sclaedSize = vector.new(width, size.y, height)

        -- Position server turtle at offsetTarget before deploying pair
        -- (Assumes server moves to position; add navigation if needed)
        
        deployPair(offsetTarget, sclaedSize, finish, options)
        os.sleep(1)
        print(string.format( "Deploying pair to: %d %d %d    %d %d",  target.x + xOffset, target.y, target.z + zOffset, sclaedSize.x, sclaedSize.z))
    end

    -- All pairs deployed, wait for last pair finished signal
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    turtle.digUp()

end