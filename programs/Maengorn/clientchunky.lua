--CHUNKY TURTLE CLIENT--

local SLOT_COUNT = 16

local CLIENT_PORT = 1
local SERVER_PORT = 420
local CHUNKY_PORT = 421

local modem = peripheral.wrap("right")
modem.open(CLIENT_PORT)
modem.open(CHUNKY_PORT)

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

function parseChunkyParams(data)
    params = split(data, " ")
    
    local startCoords = vector.new(params[1], params[2], params[3])
    local turtleId = tonumber(params[4])

    return startCoords, turtleId
end

function checkFuel()
    turtle.select(1)
    
    if(turtle.getFuelLevel() < 50) then
        print("Attempting Refuel...")
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel()) then
                return true
            end
        end
        return false
    else
        return true
    end
end

function getOrientation()
    loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j=1,6 do
            if not turtle.forward() then
                turtle.dig()
            else 
                break 
            end
        end
    end
    loc2 = vector.new(gps.locate(2, false))
    heading = loc2 - loc1
    turtle.down()
    turtle.down()
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
end

function turnToFaceHeading(heading, destinationHeading)
    if(heading > destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnLeft()
        end
    elseif(heading < destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnRight()
        end
    end
end

function setHeadingZ(zDiff, heading)
    local destinationHeading = heading
    if(zDiff < 0) then
        destinationHeading = 2
    elseif(zDiff > 0) then
        destinationHeading = 4
    end
    turnToFaceHeading(heading, destinationHeading)

    return destinationHeading
end

function setHeadingX(xDiff, heading)
    local destinationHeading = heading
    if(xDiff < 0) then
        destinationHeading = 1
    elseif(xDiff > 0) then
        destinationHeading = 3
    end

    turnToFaceHeading(heading, destinationHeading)
    return destinationHeading
end

function digAndMove(n)
    for x = 1, n, 1 do
        while(turtle.detect()) do
            turtle.dig()
        end
        turtle.forward()
        checkFuel()
    end
end

function digAndMoveDown(n)
    for y = 1, n, 1 do
        while(turtle.detectDown()) do
            turtle.digDown()
        end
        turtle.down()
        checkFuel()
    end
end

function digAndMoveUp(n)
    for y = 1, n, 1 do
        while(turtle.detectUp()) do
            turtle.digUp()
        end
        turtle.up()
        checkFuel()
    end
end

function moveTo(coords, heading)
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Chunky turtle moving - Distances: %d %d %d", xDiff, yDiff, zDiff))

    -- Move to X start
    heading = setHeadingX(xDiff, heading)
    digAndMove(math.abs(xDiff))

    -- Move to Z start
    heading = setHeadingZ(zDiff, heading)
    digAndMove(math.abs(zDiff))

    -- Move to Y start
    if(yDiff < 0) then    
        digAndMoveDown(math.abs(yDiff))
    elseif(yDiff > 0) then
        digAndMoveUp(math.abs(yDiff))
    end

    return heading
end

function followMiningTurtle(myTurtleId)
    print(string.format("Chunky turtle %d waiting for mining turtle commands...", myTurtleId))
    
    while true do
        local event, side, senderChannel, replyChannel, message, distance = os.pullEvent("modem_message")
        
        if senderChannel == CHUNKY_PORT then
            local msgParts = split(message, ":")
            local turtleId = tonumber(msgParts[1])
            local command = msgParts[2]
            
            -- Only respond to messages for our paired turtle
            if turtleId == myTurtleId then
                print(string.format("Chunky turtle %d received: %s", myTurtleId, command))
                
                if command == "MINING_START" then
                    print("Mining turtle started - keeping chunk loaded")
                    -- Stay in position to keep chunk loaded
                    
                elseif command == "MINING_COMPLETE" then
                    print("Mining turtle finished - mission complete")
                    break
                    
                elseif command:find("MOVE_TO") then
                    -- Extract coordinates from command like "MOVE_TO:x,y,z"
                    local coords = split(command:sub(9), ",")
                    if #coords == 3 then
                        local targetPos = vector.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
                        print(string.format("Moving to follow mining turtle at %d %d %d", targetPos.x, targetPos.y, targetPos.z))
                        moveTo(targetPos, getOrientation())
                    end
                end
            end
        end
        
        -- Small delay to prevent spam
        os.sleep(0.1)
    end
end

-- Notify server that chunky turtle is deployed
modem.transmit(SERVER_PORT, CLIENT_PORT, "CHUNKY_DEPLOYED")

-- Wait for pairing information
event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
local startCoords, turtleId = parseChunkyParams(msg)

print(string.format("Chunky turtle %d deployed at %d %d %d", turtleId, startCoords.x, startCoords.y, startCoords.z))

-- Pick up fuel
turtle.suckDown(10)
checkFuel()

-- Move to starting position (next to mining turtle)
local heading = moveTo(startCoords, getOrientation())

-- Face north
local NORTH_HEADING = 2
turnToFaceHeading(heading, NORTH_HEADING)

print(string.format("Chunky turtle %d ready - paired with mining turtle %d", turtleId, turtleId))

-- Start following the mining turtle
followMiningTurtle(turtleId)

print(string.format("Chunky turtle %d mission complete", turtleId))
