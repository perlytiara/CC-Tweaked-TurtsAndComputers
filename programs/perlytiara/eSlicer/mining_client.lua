--eSlicer MINING CLIENT--
--Enhanced mining turtle with tClear-style triple digging
--Coordinates with chunky turtle for chunk loading

local SLOT_COUNT = 16
local CLIENT_PORT = 0
local SERVER_PORT = 420
local CHUNKY_PORT = 421

local modem = peripheral.wrap("right")
modem.open(CLIENT_PORT)

-- Basic movement functions (from tClear)
local function gf(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.forward() do end end end
local function gb(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.back() do end end end
local function gu(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.up() do end end end
local function gd(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.down() do end end end
local function gl(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.turnLeft() do end end end
local function gr(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.turnRight() do end end end

local function df() turtle.dig() end
local function du() turtle.digUp() end
local function dd() turtle.digDown() end

local function dfs() while turtle.dig() do end end
local function dus() while turtle.digUp() do end end
local function dds() while turtle.digDown() do end end

-- Enhanced movement with digging (from tClear)
local function gfs(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.forward() do df() end end end
local function gus(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.up() do du() end end end
local function gds(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.down() do dd() end end end

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
    local coords = {}
    local params = split(data, " ")
    
    coords[1] = vector.new(params[1], params[2], params[3])  -- start coords
    coords[2] = vector.new(params[4], params[5], params[6])  -- size
    coords[3] = vector.new(params[7], params[8], params[9])  -- end coords
    coords[4] = tonumber(params[10])                         -- turtle ID
    
    return coords
end

function checkFuel()
    if turtle.getFuelLevel() < 50 then
        print("Attempting Refuel...")
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if turtle.refuel() then
                return true
            end
        end
        return false
    else
        return true
    end
end

function getOrientation()
    local loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j = 1, 6 do
            if not turtle.forward() then
                turtle.dig()
            else 
                break 
            end
        end
    end
    local loc2 = vector.new(gps.locate(2, false))
    local heading = loc2 - loc1
    turtle.back()
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
end

function turnToFaceHeading(heading, destinationHeading)
    if heading > destinationHeading then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnLeft()
        end
    elseif heading < destinationHeading then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnRight()
        end
    end
end

function setHeadingZ(zDiff, heading)
    local destinationHeading = heading
    if zDiff < 0 then
        destinationHeading = 2
    elseif zDiff > 0 then
        destinationHeading = 4
    end
    turnToFaceHeading(heading, destinationHeading)
    return destinationHeading
end

function setHeadingX(xDiff, heading)
    local destinationHeading = heading
    if xDiff < 0 then
        destinationHeading = 1
    elseif xDiff > 0 then
        destinationHeading = 3
    end
    turnToFaceHeading(heading, destinationHeading)
    return destinationHeading
end

function digAndMove(n)
    for x = 1, n, 1 do
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()
        checkFuel()
    end
end

function digAndMoveDown(n)
    for y = 1, n, 1 do
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
        checkFuel()
    end
end

function digAndMoveUp(n)
    for y = 1, n, 1 do
        while turtle.detectUp() do
            turtle.digUp()
        end
        turtle.up()
        checkFuel()
    end
end

function moveTo(coords, heading)
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Moving to start position - distances: %d %d %d", xDiff, yDiff, zDiff))

    -- Move to X coordinate
    heading = setHeadingX(xDiff, heading)
    digAndMove(math.abs(xDiff))

    -- Move to Z coordinate
    heading = setHeadingZ(zDiff, heading)
    digAndMove(math.abs(zDiff))

    -- Move to Y coordinate
    if yDiff < 0 then    
        digAndMoveDown(math.abs(yDiff))
    elseif yDiff > 0 then
        digAndMoveUp(math.abs(yDiff))
    end

    return heading
end

-- Inventory management
local DROPPED_ITEMS = {
    "minecraft:stone",
    "minecraft:dirt",
    "minecraft:basalt",
    "minecraft:granite", 
    "minecraft:cobblestone",
    "minecraft:sand",
    "minecraft:gravel",
    "minecraft:redstone",
    "minecraft:flint"
}

function dropItems()
    print("Purging inventory of unwanted items...")
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if item ~= nil then
            for filterIndex = 1, #DROPPED_ITEMS, 1 do
                if item["name"] == DROPPED_ITEMS[filterIndex] then
                    turtle.select(slot)
                    turtle.dropDown()
                    break
                end
            end
        end
    end
end

function getEnderIndex()
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if item ~= nil then
            if item["name"] == "enderstorage:ender_storage" then
                return slot
            end
        end
    end
    return nil
end

function manageInventory()
    dropItems()
    local index = getEnderIndex()
    if index ~= nil then
        turtle.select(index)
        turtle.digUp()      
        turtle.placeUp()  
        
        -- Store valuable items
        for slot = 1, SLOT_COUNT, 1 do
            local item = turtle.getItemDetail(slot)
            if item ~= nil then
                if item["name"] ~= "minecraft:coal_block" and 
                   item["name"] ~= "minecraft:coal" and 
                   item["name"] ~= "minecraft:charcoal" and
                   item["name"] ~= "enderstorage:ender_storage" then
                    turtle.select(slot)
                    turtle.dropUp()
                end
            end
        end
        
        turtle.digUp()
    end
end

-- Enhanced tClear-style mining algorithm
local blnDigUp = false
local blnDigDown = false
local tPos = {1, 0, 1, 0} -- x, y, z, facing

function digUpDown()
    if blnDigUp then dus() end
    if blnDigDown then dds() end
end

function gfPosDig(n)
    if n == nil then n = 1 end
    for i = 1, n, 1 do
        gfs()
        digUpDown()
    end
end

function notifyChunky(turtleId, message)
    modem.transmit(CHUNKY_PORT, CLIENT_PORT, tostring(turtleId) .. ":" .. message)
end

function tClearMine(digDeep, digWide, digHeight, turtleId)
    print(string.format("Starting tClear-style mining: %dx%dx%d", digDeep, digWide, digHeight))
    
    -- Notify chunky turtle we're starting
    notifyChunky(turtleId, "MINING_START")
    
    local remainingDigHeight = digHeight
    local blnLayerByLayer = false -- Use triple digging mode
    
    -- Step into area
    gfPosDig()
    gr() -- Face right to start mining pattern
    
    -- Position for triple digging if height allows
    if digHeight > 2 then
        gus(digHeight - 2)
    end
    
    local layerCount = 0
    while remainingDigHeight > 0 do
        layerCount = layerCount + 1
        print(string.format("Mining layer %d (remaining height: %d)", layerCount, remainingDigHeight))
        
        -- Set digging mode for this layer
        if not blnLayerByLayer then
            if tPos[3] > 1 then
                blnDigUp = true
                blnDigDown = true
            elseif remainingDigHeight == 2 then
                blnDigUp = true
                blnDigDown = false
            else
                blnDigUp = false
                blnDigDown = false
            end
        end
        
        -- Mine the layer using serpentine pattern
        for iy = 1, digDeep, 1 do
            if iy == 1 then
                gfPosDig() -- First row
            elseif iy % 2 == 0 then
                -- U-turn left
                gl() 
                gfPosDig() 
                gl()
            else 
                -- U-turn right
                gr() 
                gfPosDig() 
                gr()
            end
            
            -- Mine the width of this row
            gfPosDig(digWide - 2) 
            
            -- Handle inventory every few rows
            if iy % 3 == 0 then
                manageInventory()
            end
            
            -- Return pattern for last row
            if iy == digDeep then
                if iy % 2 == 1 then
                    -- Return to start of area
                    gl(2) 
                    gfPosDig(digWide - 2)
                end
                
                -- Return to first column
                gfPosDig() 
                gl() 
                gfPosDig(digDeep - 1) 
                gl()
            end
            
            -- Update chunky turtle position periodically
            if iy % 2 == 0 then
                local currX, currY, currZ = gps.locate()
                if currX and currY and currZ then
                    notifyChunky(turtleId, string.format("MOVE_TO:%d,%d,%d", currX, currY, currZ))
                end
            end
        end
        
        -- Adjust remaining height
        remainingDigHeight = remainingDigHeight - 1
        if blnDigUp then remainingDigHeight = remainingDigHeight - 1 end
        if blnDigDown then remainingDigHeight = remainingDigHeight - 1 end
        
        -- Move to next layer if needed
        if remainingDigHeight > 0 then
            if remainingDigHeight >= 2 then
                gds(3)
            else
                gds(tPos[3] - 1)
            end
        end
    end
    
    -- Return to ground level
    gds(tPos[3] - 1)
    
    -- Exit the mined area
    gl()
    gb()
    
    print("Mining section completed!")
    notifyChunky(turtleId, "MINING_COMPLETE")
end

-- Main client execution
print("eSlicer Mining Client v1.0")

-- Notify server of deployment
modem.transmit(SERVER_PORT, CLIENT_PORT, "MINING_DEPLOYED")

-- Wait for mining parameters
print("Waiting for mining parameters...")
local event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
local data = parseParams(msg)

local startCoords = data[1]
local mineSize = data[2] 
local endCoords = data[3]
local turtleId = data[4]

print(string.format("Mining turtle %d assigned section at %d %d %d", 
    turtleId, startCoords.x, startCoords.y, startCoords.z))
print(string.format("Section size: %dx%dx%d", mineSize.x, mineSize.y, mineSize.z))

-- Get fuel
turtle.suckDown(math.ceil(mineSize.x * mineSize.y * mineSize.z / 80) + 10)
checkFuel()

-- Get ender chest if available
if turtle.suck(1) then
    print("Ender chest acquired for inventory management")
end

-- Move to starting position
local heading = moveTo(startCoords, getOrientation())

-- Face north for consistent orientation
local NORTH_HEADING = 2
turnToFaceHeading(heading, NORTH_HEADING)

-- Start mining operation
tClearMine(mineSize.z, mineSize.x, mineSize.y, turtleId)

-- Final inventory management
manageInventory()

-- Return to base
print("Returning to base...")
moveTo(endCoords, getOrientation())

print(string.format("Mining turtle %d mission complete!", turtleId))
modem.transmit(SERVER_PORT, CLIENT_PORT, "MINING_COMPLETE")
