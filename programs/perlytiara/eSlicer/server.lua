--eSlicer SERVER--
--Enhanced mining system with paired mining and chunky turtles
--Inspired by Maengorn's system and tClear's digging algorithm

local SERVER_PORT = 420
local CLIENT_PORT = 0
local CHUNKY_PORT = 421
local SLOT_COUNT = 16

local segmentation = 5
if (#arg == 1) then
    segmentation = tonumber(arg[1])
elseif (#arg == 0) then
    print(string.format("No segmentation size selected, defaulting to %d", segmentation))
else
    print('Too many args given...')
    os.exit(1)
end

local modem = peripheral.wrap("right")
modem.open(SERVER_PORT)

local target = vector.new()
local size = vector.new()
local finish = vector.new()

-- Utility functions
function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
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
    return nil
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

function getItemFromChest(itemName, side)
    -- Try to get item from chest on specified side
    if peripheral.isPresent(side) then
        local chest = peripheral.wrap(side)
        local items = chest.list()
        
        for slot, item in pairs(items) do
            if item.name == itemName then
                chest.pushItems(peripheral.getName(turtle), slot, 1)
                return true
            end
        end
    end
    return false
end

function getMiningTurtleFromLeftChest()
    -- Get mining turtle from left chest
    local slot = getItemIndex("computercraft:turtle_advanced")
    if slot then
        return slot
    end
    
    -- Try to get from left chest (mining turtles)
    if getItemFromChest("computercraft:turtle_advanced", "left") then
        return getItemIndex("computercraft:turtle_advanced")
    end
    
    return nil
end

function getChunkyTurtleFromRightChest()
    -- Get chunky turtle from right chest
    local slot = getItemIndex("computercraft:turtle_advanced") 
    if slot then
        return slot
    end
    
    -- Try to get from right chest (chunky turtles)
    if getItemFromChest("computercraft:turtle_advanced", "right") then
        return getItemIndex("computercraft:turtle_advanced")
    end
    
    return nil
end

function deployTurtlePair(startCoords, quarySize, endCoords, turtleId)
    print(string.format("Deploying turtle pair %d...", turtleId))
    
    -- Clear inventory to ensure we have space
    for i = 1, SLOT_COUNT do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            -- Try to put items back in chests if they're not coal/fuel
            local item = turtle.getItemDetail()
            if item and item.name ~= "minecraft:coal" and item.name ~= "minecraft:charcoal" and item.name ~= "minecraft:coal_block" then
                turtle.dropUp() -- Drop into back chest or void
            end
        end
    end
    
    -- Get mining turtle from left chest
    local miningSlot = getMiningTurtleFromLeftChest()
    if not miningSlot then
        print("Warning: No mining turtle available in left chest, skipping deployment")
        return false
    end
    
    -- Place mining turtle in front (towards mining area)
    turtle.select(miningSlot)
    while turtle.detect() do
        os.sleep(0.3)
        print("Waiting for space to deploy mining turtle...")
    end
    
    turtle.place()
    print("Mining turtle deployed in front")
    
    -- Move to disk drive position (front-left) to set up programs
    turtle.forward() -- Move to front row
    turtle.turnLeft() -- Face left towards disk drive
    
    -- Set up disk programs for mining turtle
    if peripheral.isPresent("front") and peripheral.getType("front") == "drive" then
        -- Disk drive is in front-left position
        local diskDrive = peripheral.wrap("front")
        
        -- Write startup for mining turtle
        if fs.exists("disk/startup") then fs.delete("disk/startup") end
        if fs.exists("disk/mining_client") then fs.delete("disk/mining_client") end
        
        local startupFile = fs.open("disk/startup", "w")
        startupFile.write([[
-- eSlicer Mining Turtle Startup
if fs.exists("disk/mining_client") then
    fs.copy("disk/mining_client", "/mining_client")
    shell.run("mining_client")
else
    print("Error: mining_client not found on disk!")
end
]])
        startupFile.close()
        
        -- Copy mining client to disk
        if fs.exists("mining_client") then
            fs.copy("mining_client", "disk/mining_client")
        end
    else
        print("Warning: No disk drive found at front-left position!")
    end
    
    -- Return to server position and face forward
    turtle.turnRight() -- Face forward
    turtle.back() -- Return to server position
    
    -- Turn on mining turtle
    peripheral.call("front", "turnOn")
    
    -- Wait for mining client to deploy
    local event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    if msg ~= "MINING_DEPLOYED" then
        print("No mining client deploy message, continuing...")
    end
    
    -- Turn right to face right chest
    turtle.turnRight()
    
    -- Get chunky turtle from right chest  
    local chunkySlot = getChunkyTurtleFromRightChest()
    if not chunkySlot then
        print("Warning: No chunky turtle available in right chest, mining turtle will work alone")
        turtle.turnLeft() -- Turn back to original orientation
        
        -- Send mining parameters without chunky pair
        modem.transmit(CLIENT_PORT, SERVER_PORT,
            string.format("%d %d %d %d %d %d %d %d %d %d", 
            startCoords.x, startCoords.y, startCoords.z,
            quarySize.x, quarySize.y, quarySize.z,
            endCoords.x, endCoords.y, endCoords.z,
            turtleId
        ))
        return true
    end
    
    -- Move forward to deploy chunky turtle next to mining turtle
    turtle.forward()
    
    -- Place chunky turtle
    turtle.select(chunkySlot)
    while turtle.detect() do
        os.sleep(0.3)
        print("Waiting for space to deploy chunky turtle...")
    end
    
    turtle.place()
    print("Chunky turtle deployed next to mining turtle")
    
    -- Move back to access disk drive for chunky turtle
    turtle.back() -- Move back to server row
    turtle.turnLeft() -- Face left
    turtle.forward() -- Move to disk drive position
    
    -- Set up disk programs for chunky turtle
    if peripheral.isPresent("front") and peripheral.getType("front") == "drive" then
        -- Disk drive is in front-left position
        local diskDrive = peripheral.wrap("front")
        
        -- Write startup for chunky turtle  
        if fs.exists("disk/startup") then fs.delete("disk/startup") end
        if fs.exists("disk/chunky_client") then fs.delete("disk/chunky_client") end
        
        local startupFile = fs.open("disk/startup", "w")
        startupFile.write([[
-- eSlicer Chunky Turtle Startup
if fs.exists("disk/chunky_client") then
    fs.copy("disk/chunky_client", "/chunky_client")
    shell.run("chunky_client")
else
    print("Error: chunky_client not found on disk!")
end
]])
        startupFile.close()
        
        -- Copy chunky client to disk
        if fs.exists("chunky_client") then
            fs.copy("chunky_client", "disk/chunky_client")
        end
    else
        print("Warning: No disk drive found for chunky turtle setup!")
    end
    
    -- Return to chunky turtle position
    turtle.back() -- Back to server row
    turtle.turnRight() -- Face right again
    turtle.forward() -- Back to chunky position
    
    -- Turn on chunky turtle
    peripheral.call("front", "turnOn")
    
    -- Return to original position
    turtle.back()
    turtle.turnLeft() -- Face forward again
    
    -- Wait for chunky client deployment
    event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
    if msg ~= "CHUNKY_DEPLOYED" then
        print("No chunky client deploy message, continuing...")
    end
    
    checkFuel()
    
    -- Send mining parameters to both turtles
    modem.transmit(CLIENT_PORT, SERVER_PORT,
        string.format("%d %d %d %d %d %d %d %d %d %d", 
        startCoords.x, startCoords.y, startCoords.z,
        quarySize.x, quarySize.y, quarySize.z,
        endCoords.x, endCoords.y, endCoords.z,
        turtleId
    ))
    
    -- Send chunky pairing info
    modem.transmit(CHUNKY_PORT, SERVER_PORT,
        string.format("%d %d %d %d", 
        startCoords.x, startCoords.y, startCoords.z,
        turtleId
    ))
    
    print(string.format("Turtle pair %d deployed and configured!", turtleId))
    return true
end

-- Calculate segmentation for turtle deployment
function getPositioningTable(x, z, segmentationSize)
    local xRemainder = x % segmentationSize
    local zRemainder = z % segmentationSize

    local xMain = x - xRemainder
    local zMain = z - zRemainder

    xRemainder = (xRemainder == 0 and segmentationSize or xRemainder)
    zRemainder = (zRemainder == 0 and segmentationSize or zRemainder)

    local positions = {}

    for zi = 0, z - 1, segmentationSize do
        for xi = 0, x - 1, segmentationSize do
            local dims = {xi, zi, segmentationSize, segmentationSize}
            
            if(xi >= x - segmentationSize and xi <= x - 1) then
                dims = {xi, zi, xRemainder, segmentationSize}
            end
            
            if(zi >= z - segmentationSize and zi <= z - 1) then
                dims = {xi, zi, segmentationSize, zRemainder}
            end
            
            table.insert(positions, dims)
        end
    end
    
    return table.pack(positions, xRemainder, zRemainder)
end

-- Main server loop
print("eSlicer Server v1.0 - Enhanced Mining System")
print("Setup: [Left Chest: Mining] [Server] [Right Chest: Chunky]")
print("       [Disk Drive in front-left with programs]")
print("Turtles deploy in front: [Disk] [Mining] [Chunky]")

while (true) do
    print("Waiting for mining request signal...")
    local event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")

    -- Parse coordinates
    local data = parseParams(msg)
    target = data[1]
    size = data[2]

    finish = vector.new(gps.locate())
    finish.y = finish.y + 1
    
    print(string.format("RECEIVED MINING REQUEST AT: %d %d %d", target.x, target.y, target.z))
    print(string.format("SIZE: %dx%dx%d", size.x, size.y, size.z))

    local tab, xDf, zDf = table.unpack(getPositioningTable(size.x, size.z, segmentation))

    print(string.format("Deploying %d turtle pairs...", #tab))
    
    for i = 1, #tab, 1 do
        local xOffset, zOffset, width, depth = table.unpack(tab[i])
        local offsetTarget = vector.new(target.x + xOffset, target.y, target.z + zOffset)
        local scaledSize = vector.new(width, size.y, depth)

        print(string.format("Deploying pair %d to: %d %d %d (size: %dx%dx%d)", 
            i, offsetTarget.x, offsetTarget.y, offsetTarget.z, 
            scaledSize.x, scaledSize.y, scaledSize.z))
        
        if deployTurtlePair(offsetTarget, scaledSize, finish, i) then
            os.sleep(2) -- Give turtles time to initialize
        end
    end

    print("All turtle pairs deployed! Waiting for completion...")
    
    -- Wait for completion signals
    for i = 1, #tab do
        event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
        if msg == "MINING_COMPLETE" then
            print(string.format("Turtle pair %d completed mining", i))
        end
    end
    
    print("All mining operations completed!")
end
