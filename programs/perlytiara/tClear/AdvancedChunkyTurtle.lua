--{program="AdvancedChunkyTurtle",version="2.0",date="2024-12-19"}
---------------------------------------
-- Advanced Chunky Turtle             by AI Assistant
-- 2024-12-19, v2.0   Enhanced chunky turtle with improved following
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Enhanced chunky turtle with advanced wireless communication
-- Follows mining turtle to keep chunks loaded and prevent turtle breaking
-- Features improved movement, better error handling, and status reporting
-- Based on original tClearChunky.lua with wireless enhancements

---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Requires a wireless turtle with wireless modem
-- Should be placed one block to the right of the mining turtle
-- No tools needed - only follows and keeps chunks loaded

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v2.0"
local cPrgName = "AdvancedChunkyTurtle"
local blnDebugPrint = true

-- Communication settings
local protocol = "advanced-mining"
local chunkyProtocol = "tclear-chunky"
local masterTurtleId = nil
local controllerId = nil
local isActive = false
local isPaired = false

-- Position tracking
local position = {x = 0, y = 0, z = 1, facing = 0} -- relative to master (to the right)
local targetPosition = {x = 0, y = 0, z = 1, facing = 0}
local lastKnownMasterPosition = {x = 0, y = 0, z = 0, facing = 0}

-- Operation settings
local chunkLoadingInterval = 2 -- seconds between chunk loading signals
local statusReportInterval = 10 -- seconds between status reports
local lastChunkLoad = 0
local lastStatusReport = 0
local lastBroadcast = 0
local broadcastInterval = 5 -- seconds

-- Movement settings
local maxRetries = 3
local retryDelay = 0.5 -- seconds

---------------------------------------
---- Utility Functions ----------------
---------------------------------------
local function debugPrint(str)
    if blnDebugPrint then
        print("[ChunkyTurtle] " .. str)
    end
end

local function findModem()
    for _, p in pairs(rs.getSides()) do
        if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
            return p
        end
    end
    error("No wireless modem attached to this turtle.")
end

local function sendMessage(targetId, message, customProtocol)
    local protocolToUse = customProtocol or protocol
    rednet.send(targetId, message, protocolToUse)
    debugPrint("Sent to " .. targetId .. ": " .. textutils.serialize(message))
end

local function sendStatus(status, data)
    local targetId = controllerId or masterTurtleId
    if targetId then
        sendMessage(targetId, {
            type = "status",
            status = status,
            id = os.getComputerID(),
            position = position,
            data = data or {},
            timestamp = os.time()
        })
    end
end

local function sendChunkLoad()
    if masterTurtleId then
        sendMessage(masterTurtleId, {
            type = "chunk_load",
            id = os.getComputerID(),
            position = position,
            timestamp = os.time()
        }, chunkyProtocol)
    end
end

---------------------------------------
---- Movement Functions ---------------
---------------------------------------
local function safeMove(moveFunction, direction)
    local retries = 0
    while retries < maxRetries do
        if moveFunction() then
            return true
        else
            retries = retries + 1
            if retries < maxRetries then
                debugPrint("Move failed, retrying " .. direction .. " (attempt " .. retries .. ")")
                sleep(retryDelay)
            end
        end
    end
    debugPrint("Failed to move " .. direction .. " after " .. maxRetries .. " attempts")
    return false
end

local function safeDig(digFunction, direction)
    local retries = 0
    while retries < maxRetries do
        if digFunction() then
            return true
        else
            retries = retries + 1
            if retries < maxRetries then
                debugPrint("Dig failed, retrying " .. direction .. " (attempt " .. retries .. ")")
                sleep(retryDelay)
            end
        end
    end
    debugPrint("Failed to dig " .. direction .. " after " .. maxRetries .. " attempts")
    return false
end

local function moveTo(targetX, targetY, targetZ, targetFacing)
    -- Calculate relative movement needed from current position to target
    local dx = targetX - position.x
    local dy = targetY - position.y
    local dz = targetZ - position.z
    local dfacing = (targetFacing - position.facing) % 4
    
    debugPrint("Moving from (" .. position.x .. "," .. position.y .. "," .. position.z .. ") to (" .. targetX .. "," .. targetY .. "," .. targetZ .. ")")
    debugPrint("Delta: dx=" .. dx .. " dy=" .. dy .. " dz=" .. dz .. " dfacing=" .. dfacing)
    
    -- Turn to correct facing first
    if dfacing == 1 then
        turtle.turnRight()
        position.facing = (position.facing + 1) % 4
    elseif dfacing == 2 then
        turtle.turnRight()
        turtle.turnRight()
        position.facing = (position.facing + 2) % 4
    elseif dfacing == 3 then
        turtle.turnLeft()
        position.facing = (position.facing - 1) % 4
    end
    
    -- Move vertically first (up)
    while dy > 0 do
        if safeMove(turtle.up, "up") then
            dy = dy - 1
            position.y = position.y + 1
            debugPrint("Moved up to y=" .. position.y)
        else
            debugPrint("Cannot move up, trying to dig")
            if safeDig(turtle.digUp, "up") then
                sleep(0.1)
                if safeMove(turtle.up, "up") then
                    dy = dy - 1
                    position.y = position.y + 1
                    debugPrint("Moved up to y=" .. position.y)
                else
                    debugPrint("Still blocked after digging up")
                    break
                end
            else
                debugPrint("Cannot dig up, giving up")
                break
            end
        end
    end
    
    -- Move vertically (down)
    while dy < 0 do
        if safeMove(turtle.down, "down") then
            dy = dy + 1
            position.y = position.y - 1
            debugPrint("Moved down to y=" .. position.y)
        else
            debugPrint("Cannot move down, trying to dig")
            if safeDig(turtle.digDown, "down") then
                sleep(0.1)
                if safeMove(turtle.down, "down") then
                    dy = dy + 1
                    position.y = position.y - 1
                    debugPrint("Moved down to y=" .. position.y)
                else
                    debugPrint("Still blocked after digging down")
                    break
                end
            else
                debugPrint("Cannot dig down, giving up")
                break
            end
        end
    end
    
    -- Move horizontally - handle X movement (forward/backward relative to facing)
    while dx > 0 do
        if safeMove(turtle.forward, "forward") then
            dx = dx - 1
            position.x = position.x + 1
            debugPrint("Moved forward to x=" .. position.x)
        else
            debugPrint("Blocked forward, trying to dig")
            if safeDig(turtle.dig, "forward") then
                sleep(0.1)
                if safeMove(turtle.forward, "forward") then
                    dx = dx - 1
                    position.x = position.x + 1
                    debugPrint("Moved forward to x=" .. position.x)
                else
                    debugPrint("Still blocked after digging forward")
                    break
                end
            else
                debugPrint("Cannot dig forward, giving up")
                break
            end
        end
    end
    
    while dx < 0 do
        -- Turn around to move backward
        turtle.turnLeft()
        turtle.turnLeft()
        if safeMove(turtle.forward, "backward") then
            dx = dx + 1
            position.x = position.x - 1
            debugPrint("Moved backward to x=" .. position.x)
        else
            debugPrint("Blocked backward, trying to dig")
            if safeDig(turtle.dig, "backward") then
                sleep(0.1)
                if safeMove(turtle.forward, "forward") then
                    dx = dx + 1
                    position.x = position.x - 1
                    debugPrint("Moved backward to x=" .. position.x)
                else
                    debugPrint("Still blocked after digging backward")
                end
            else
                debugPrint("Cannot dig backward, giving up")
            end
        end
        turtle.turnLeft()
        turtle.turnLeft()
        if dx < 0 then break end -- If still can't move, give up
    end
    
    -- Move sideways - handle Z movement (left/right relative to facing)
    while dz > 0 do
        turtle.turnRight()
        if safeMove(turtle.forward, "right") then
            dz = dz - 1
            position.z = position.z + 1
            debugPrint("Moved right to z=" .. position.z)
        else
            debugPrint("Blocked right, trying to dig")
            if safeDig(turtle.dig, "right") then
                sleep(0.1)
                if safeMove(turtle.forward, "right") then
                    dz = dz - 1
                    position.z = position.z + 1
                    debugPrint("Moved right to z=" .. position.z)
                else
                    debugPrint("Still blocked after digging right")
                end
            else
                debugPrint("Cannot dig right, giving up")
            end
        end
        turtle.turnLeft()
        if dz > 0 then break end -- If still can't move, give up
    end
    
    while dz < 0 do
        turtle.turnLeft()
        if safeMove(turtle.forward, "left") then
            dz = dz + 1
            position.z = position.z - 1
            debugPrint("Moved left to z=" .. position.z)
        else
            debugPrint("Blocked left, trying to dig")
            if safeDig(turtle.dig, "left") then
                sleep(0.1)
                if safeMove(turtle.forward, "left") then
                    dz = dz + 1
                    position.z = position.z - 1
                    debugPrint("Moved left to z=" .. position.z)
                else
                    debugPrint("Still blocked after digging left")
                end
            else
                debugPrint("Cannot dig left, giving up")
            end
        end
        turtle.turnRight()
        if dz < 0 then break end -- If still can't move, give up
    end
    
    -- Update final facing
    position.facing = targetFacing
    debugPrint("Final position: (" .. position.x .. "," .. position.y .. "," .. position.z .. ") facing=" .. position.facing)
    
    -- Update target position
    targetPosition = {x = targetX, y = targetY, z = targetZ, facing = targetFacing}
end

---------------------------------------
---- Message Processing ---------------
---------------------------------------
local function processMessage(senderId, message, msgProtocol)
    if message.type == "discover" then
        -- Respond to discovery request
        sendMessage(senderId, {
            type = "chunky_turtle_available",
            name = "Advanced Chunky Turtle",
            fuel = turtle.getFuelLevel(),
            timestamp = os.time()
        })
        return true
        
    elseif message.type == "start_chunky" then
        -- Start chunky mode
        masterTurtleId = message.masterId
        controllerId = senderId
        isActive = true
        isPaired = true
        
        print("SUCCESS: Paired with master turtle " .. masterTurtleId)
        print("Chunky turtle is now active and ready to follow!")
        
        sendStatus("paired", {chunkyId = os.getComputerID()})
        
        -- Send ready confirmation
        sendMessage(controllerId, {
            type = "chunky_ready",
            chunkyId = os.getComputerID(),
            timestamp = os.time()
        })
        
        return true
        
    elseif message.type == "move" then
        if isActive and message.target then
            debugPrint("Moving to " .. message.target.x .. "," .. message.target.y .. "," .. message.target.z)
            moveTo(message.target.x, message.target.y, message.target.z, message.target.facing or 0)
            sendStatus("moved", {position = position})
            return true
        end
        
    elseif message.type == "stop" or message.type == "stop_operation" then
        isActive = false
        isPaired = false
        debugPrint("Stopped by master turtle")
        sendStatus("stopped", {})
        return true
        
    elseif message.type == "ping" then
        sendStatus("alive", {position = position})
        return true
    end
    
    return false
end

---------------------------------------
---- Main Program ----------------------
---------------------------------------
local function main()
    term.clear()
    term.setCursorPos(1, 1)
    
    print("==========================================")
    print("  Advanced Chunky Turtle " .. cVersion)
    print("==========================================")
    print()
    
    -- Initialize rednet
    local modemSide = findModem()
    rednet.open(modemSide)
    print("Rednet initialized on " .. modemSide)
    
    local thisId = os.getComputerID()
    print("Chunky turtle ID: " .. thisId)
    print()
    print("Waiting for pairing with master turtle...")
    print("Press Ctrl+T to exit")
    
    -- Send initial broadcast
    sendMessage(0, {
        type = "chunky_turtle_available",
        id = thisId,
        timestamp = os.time()
    })
    
    print("Sent initial broadcast - waiting for master turtle...")
    
    -- Main loop
    while true do
        local timer = os.startTimer(0.1) -- Check for messages every 0.1 seconds
        
        -- Handle rednet messages
        local senderId, message, msgProtocol = rednet.receive(0.1)
        if senderId then
            -- Accept messages on multiple protocols
            if msgProtocol == protocol or msgProtocol == chunkyProtocol or msgProtocol == "tclear-run" or msgProtocol == "tclear" or msgProtocol == nil then
                local handled = processMessage(senderId, message, msgProtocol)
                if handled then
                    debugPrint("Processed message from " .. senderId)
                end
            end
        end
        
        -- Send chunk loading signal periodically
        local currentTime = os.time()
        if isActive and (currentTime - lastChunkLoad) >= chunkLoadingInterval then
            sendChunkLoad()
            lastChunkLoad = currentTime
        end
        
        -- Send status reports periodically
        if isPaired and (currentTime - lastStatusReport) >= statusReportInterval then
            sendStatus("alive", {position = position, fuel = turtle.getFuelLevel()})
            lastStatusReport = currentTime
        end
        
        -- Send periodic broadcasts if not paired yet
        if not isPaired and (currentTime - lastBroadcast) >= broadcastInterval then
            sendMessage(0, {
                type = "chunky_turtle_available",
                id = thisId,
                timestamp = currentTime
            })
            print("Sent broadcast - still waiting for master turtle...")
            lastBroadcast = currentTime
        end
        
        -- Handle timer events (cleanup)
        local event, timerId = os.pullEvent("timer")
        if timerId == timer then
            -- Timer expired, continue loop
        end
    end
end

-- Run main program
local ok, err = pcall(main)
if not ok then
    print("Error: " .. tostring(err))
    print("Press any key to exit...")
    os.pullEvent("key")
end
