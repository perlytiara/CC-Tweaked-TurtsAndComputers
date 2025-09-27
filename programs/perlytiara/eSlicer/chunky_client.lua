--eSlicer CHUNKY CLIENT--
--Chunk loading turtle that follows mining turtle to keep chunks loaded

local SLOT_COUNT = 16
local CLIENT_PORT = 1
local SERVER_PORT = 420
local CHUNKY_PORT = 421

local modem = peripheral.wrap("right")
modem.open(CLIENT_PORT)
modem.open(CHUNKY_PORT)

-- Basic movement functions
local function gf(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.forward() do end end end
local function gb(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.back() do end end end
local function gu(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.up() do end end end
local function gd(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.down() do end end end
local function gl(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.turnLeft() do end end end
local function gr(n) if n==nil then n=1 end for i=1,n,1 do while not turtle.turnRight() do end end end

local function df() turtle.dig() end
local function du() turtle.digUp() end
local function dd() turtle.digDown() end

-- Enhanced movement with digging
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

function parseChunkyParams(data)
    local params = split(data, " ")
    local startCoords = vector.new(params[1], params[2], params[3])
    local turtleId = tonumber(params[4])
    return startCoords, turtleId
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
    if not currX then
        print("Warning: GPS unavailable, cannot move precisely")
        return heading
    end
    
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Chunky moving - distances: %d %d %d", xDiff, yDiff, zDiff))

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

function smartFollow(targetPos, currentHeading)
    -- Follow mining turtle but stay out of the way
    -- Position slightly behind and to the side
    local followPos = vector.new(targetPos.x - 2, targetPos.y, targetPos.z - 1)
    
    -- Make sure we don't go underground unnecessarily
    if followPos.y < targetPos.y then
        followPos.y = targetPos.y
    end
    
    return moveTo(followPos, currentHeading)
end

function maintainChunkLoading(myTurtleId)
    print(string.format("Chunky turtle %d maintaining chunk loading...", myTurtleId))
    
    local lastPosition = vector.new(gps.locate())
    local stationaryTime = 0
    local currentHeading = getOrientation()
    
    while true do
        local event, side, senderChannel, replyChannel, message, distance = os.pullEvent("modem_message")
        
        if senderChannel == CHUNKY_PORT then
            local msgParts = split(message, ":")
            local turtleId = tonumber(msgParts[1])
            local command = msgParts[2]
            
            -- Only respond to messages for our paired turtle
            if turtleId == myTurtleId then
                print(string.format("Chunky %d received: %s", myTurtleId, command))
                
                if command == "MINING_START" then
                    print("Mining turtle started - actively maintaining chunk loading")
                    stationaryTime = 0
                    
                elseif command == "MINING_COMPLETE" then
                    print("Mining turtle finished - mission complete")
                    break
                    
                elseif command:find("MOVE_TO") then
                    -- Extract coordinates from command like "MOVE_TO:x,y,z"
                    local coords = split(command:sub(9), ",")
                    if #coords == 3 then
                        local targetPos = vector.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
                        print(string.format("Following mining turtle to %d %d %d", targetPos.x, targetPos.y, targetPos.z))
                        currentHeading = smartFollow(targetPos, currentHeading)
                        stationaryTime = 0
                    end
                end
            end
        end
        
        -- Perform periodic maintenance
        checkFuel()
        
        -- Anti-idle behavior - move slightly to keep chunks active
        local currentPos = vector.new(gps.locate())
        if currentPos and lastPosition then
            local distance = math.abs(currentPos.x - lastPosition.x) + 
                           math.abs(currentPos.y - lastPosition.y) + 
                           math.abs(currentPos.z - lastPosition.z)
            
            if distance == 0 then
                stationaryTime = stationaryTime + 1
                if stationaryTime > 10 then
                    -- Perform small movement to keep chunk active
                    print("Performing anti-idle movement")
                    turtle.turnRight()
                    if turtle.forward() then
                        turtle.back()
                    end
                    turtle.turnLeft()
                    stationaryTime = 0
                end
            else
                stationaryTime = 0
            end
            
            lastPosition = currentPos
        end
        
        -- Small delay to prevent spam
        os.sleep(0.1)
    end
end

-- Main chunky client execution
print("eSlicer Chunky Client v1.0")

-- Notify server of deployment
modem.transmit(SERVER_PORT, CLIENT_PORT, "CHUNKY_DEPLOYED")

-- Wait for pairing information
print("Waiting for pairing information...")
local event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
local startCoords, turtleId = parseChunkyParams(msg)

print(string.format("Chunky turtle %d paired with mining turtle %d", turtleId, turtleId))
print(string.format("Positioned near %d %d %d", startCoords.x, startCoords.y, startCoords.z))

-- Get fuel
turtle.suckDown(10)
checkFuel()

-- Move to starting position (slightly offset from mining turtle)
local followStart = vector.new(startCoords.x - 1, startCoords.y, startCoords.z - 1)
local heading = moveTo(followStart, getOrientation())

-- Face north for consistency
local NORTH_HEADING = 2
turnToFaceHeading(heading, NORTH_HEADING)

print(string.format("Chunky turtle %d ready - following mining turtle %d", turtleId, turtleId))

-- Brief delay to let mining turtle initialize
os.sleep(3)

-- Start chunk loading operations
maintainChunkLoading(turtleId)

print(string.format("Chunky turtle %d mission complete", turtleId))
