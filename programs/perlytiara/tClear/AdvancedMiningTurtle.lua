--{program="AdvancedMiningTurtle",version="2.0",date="2024-12-19"}
---------------------------------------
-- Advanced Mining Turtle             by AI Assistant
-- 2024-12-19, v2.0   Enhanced wireless mining turtle
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Enhanced mining turtle with advanced wireless communication
-- Supports remote control from AdvancedMiningController
-- Features real-time status reporting, pause/resume, and chunky pairing
-- Based on original tClear.lua with wireless enhancements

---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Requires a mining turtle with wireless modem
-- Should be placed at left corner of mining area
-- Chunky turtle should be placed one block to the right

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v2.0"
local cPrgName = "AdvancedMiningTurtle"
local blnDebugPrint = true

-- Communication settings
local protocol = "advanced-mining"
local controllerId = nil
local chunkyTurtleId = nil
local isRemoteControlled = false

-- Operation state
local isOperationActive = false
local isPaused = false
local operationCommand = ""
local operationParams = {}

-- Position tracking
local tPos = {x = 1, y = 0, z = 1, facing = 0}
local startPosition = {x = 1, y = 0, z = 1, facing = 0}

-- Mining parameters
local digDeep = 0
local digWide = 0
local digHeight = 0
local blnLayerByLayer = false
local blnStartWithin = false
local blnStripMine = false

-- Status reporting
local lastStatusReport = 0
local statusReportInterval = 5 -- seconds

---------------------------------------
---- Utility Functions ----------------
---------------------------------------
local function debugPrint(str)
    if blnDebugPrint then
        print("[MiningTurtle] " .. str)
    end
end

local function findModem()
    for _, p in pairs(rs.getSides()) do
        if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
            return p
        end
    end
    error("No modem attached to this turtle.")
end

local function sendMessage(targetId, message, customProtocol)
    local protocolToUse = customProtocol or protocol
    rednet.send(targetId, message, protocolToUse)
    debugPrint("Sent to " .. targetId .. ": " .. textutils.serialize(message))
end

local function sendStatusUpdate()
    if controllerId and isOperationActive then
        local status = {
            type = "status_update",
            position = "(" .. tPos.x .. "," .. tPos.y .. "," .. tPos.z .. ")",
            progress = "Mining in progress",
            fuel = turtle.getFuelLevel(),
            inventory = math.floor((turtle.getItemCount() / (16 * 64)) * 100) .. "%",
            timestamp = os.time()
        }
        
        if chunkyTurtleId then
            status.chunkyStatus = "Paired with chunky turtle"
        end
        
        sendMessage(controllerId, status)
        lastStatusReport = os.time()
    end
end

---------------------------------------
---- Movement Functions (from tClear) -
---------------------------------------
local function gf(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.forward()   do end end end
local function gb(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.back()      do end end end
local function gu(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.up()        do end end end
local function gd(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.down()      do end end end
local function gl(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.turnLeft()  do end end end
local function gr(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.turnRight() do end end end

local function df()  turtle.dig()       end
local function du()  turtle.digUp()     end
local function dd()  turtle.digDown()   end

local function dfs()  while turtle.dig()     do end end
local function dus()  while turtle.digUp()   do end end
local function dds()  while turtle.digDown() do end end

local function ss(s) turtle.select(s)   end
local function gic(s) return turtle.getItemCount(s) end

local function gfs(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.forward() do df() end end end
local function gbs(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.back()    do gl() gl() df() gr() gr() end end end
local function gus(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.up()      do du() end end end
local function gds(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.down()    do dd() end end end

-- Position-aware movement functions
local function glPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.turnLeft()  do end end end
local function grPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.turnRight() do end end end
local function gfPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.forward()   do df() end end end
local function gbPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.back()      do gl() gl() df() gr() gr() end end end
local function guPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.up()        do du() end tPos[3]=tPos[3]+1 end end
local function gdPos(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.down()      do dd() end tPos[3]=tPos[3]-1 end end

---------------------------------------
---- Chunky Turtle Communication ------
---------------------------------------
local function moveChunkyTurtle(mainX, mainY, mainZ, mainFacing)
    if chunkyTurtleId then
        -- Calculate chunky turtle position relative to main turtle (to the right)
        local chunkyX = mainX      -- Same X position (depth)
        local chunkyY = mainY      -- Same height
        local chunkyZ = mainZ + 1  -- One block to the right (positive Z)
        local chunkyFacing = mainFacing  -- Same facing direction
        
        sendMessage(chunkyTurtleId, {
            type = "move",
            target = {x = chunkyX, y = chunkyY, z = chunkyZ, facing = chunkyFacing},
            timestamp = os.time()
        }, "tclear-chunky")
        
        debugPrint("Sent chunky turtle to position: (" .. chunkyX .. "," .. chunkyY .. "," .. chunkyZ .. ") facing=" .. chunkyFacing)
    end
end

local function stopChunkyTurtle()
    if chunkyTurtleId then
        sendMessage(chunkyTurtleId, {
            type = "stop",
            timestamp = os.time()
        }, "tclear-chunky")
    end
end

---------------------------------------
---- Mining Functions (from tClear) ---
---------------------------------------
local blnDigUp = false
local blnDigDown = false

local function digUpDown()
    if blnDigUp then dus() end
    if blnDigDown then dds() end
end

local function gfPosDig(n)
    if n==nil then n=1 end
    for i=1,n,1 do
        gfPos() 
        digUpDown()
    end
end

local function checkFuel()
    return turtle.getFuelLevel()
end

local function refuelFromSlot(s, n)
    if s==nil then s=16 end
    if n==nil then n=64 end
    local currentSlot = turtle.getSelectedSlot()
    local fuelItems = turtle.getItemCount(s)
    local returnValue = false

    if fuelItems>0 then 
        ss(s)
        returnValue=turtle.refuel(n)
        ss(currentSlot)
    end
    return returnValue
end

local function refuelManager(setMinFuel, setSlotFuel, waitTime)
    local currentSlotSelected = turtle.getSelectedSlot()
    ss(setSlotFuel)
    while turtle.getFuelLevel() < setMinFuel do
        print("Need more fuel (" .. turtle.getFuelLevel() .. "/" .. setMinFuel .. ").")
        if not refuelFromSlot(setSlotFuel) then
            print("  Please, put fuel items in slot " .. setSlotFuel .. "!")
            print("  Sleeping " .. waitTime .. " seconds") 
            sleep(waitTime)
        else
            print("Refueled...")
        end
    end
    ss(currentSlotSelected)
end

---------------------------------------
---- Operation Control Functions ------
---------------------------------------
local function parseOperationCommand(command)
    local args = {}
    for arg in string.gmatch(command, "%S+") do
        table.insert(args, arg)
    end
    
    if #args < 3 then
        error("Invalid command format. Expected: depth width height [options]")
    end
    
    digDeep = tonumber(args[1])
    digWide = tonumber(args[2])
    digHeight = tonumber(args[3])
    
    if not digDeep or digDeep <= 0 then
        error("Invalid depth. Must be >= 1")
    end
    if not digWide or digWide == -1 or digWide == 0 or digWide == 1 then
        error("Invalid width. Cannot be -1, 0, or 1")
    end
    if not digHeight or digHeight == 0 then
        error("Invalid height. Cannot be 0")
    end
    
    -- Parse options
    blnLayerByLayer = false
    blnStartWithin = false
    blnStripMine = false
    
    for i = 4, #args do
        local option = string.lower(args[i])
        if option == "layerbylayer" or option == "layer" or option == "singlelayer" then
            blnLayerByLayer = true
        elseif option == "startwithin" or option == "within" or option == "in" then
            blnStartWithin = true
        elseif option == "stripmine" or option == "strip" or option == "mine" then
            blnStripMine = true
        end
    end
    
    debugPrint("Parsed command: depth=" .. digDeep .. " width=" .. digWide .. " height=" .. digHeight)
    debugPrint("Options: layerbylayer=" .. tostring(blnLayerByLayer) .. " startwithin=" .. tostring(blnStartWithin) .. " stripmine=" .. tostring(blnStripMine))
end

local function performMiningOperation()
    print("Starting mining operation...")
    print("Parameters: " .. digDeep .. " x " .. digWide .. " x " .. digHeight)
    
    -- Initialize position
    tPos[1] = 1
    tPos[2] = 0
    tPos[3] = 1
    tPos[4] = 0
    startPosition = {x = tPos[1], y = tPos[2], z = tPos[3], facing = tPos[4]}
    
    -- Check fuel
    local cMinFuel = 110
    local slotFuel = 16
    
    if not blnLayerByLayer then 
        cMinFuel = math.floor(digHeight/3)
    else
        cMinFuel = math.floor(digHeight) 
    end
    cMinFuel = cMinFuel * (math.abs(digDeep) + 1) * (math.abs(digWide) + 1) + (digHeight * 2)
    cMinFuel = math.floor(cMinFuel * 1.1) + 20
    
    refuelManager(cMinFuel, slotFuel, 10)
    
    -- Handle negative values
    local digWideOrg = digWide
    local digDeepOrg = digDeep
    local blnNegativeWidth = false
    
    if digWide < 0 then
        blnNegativeWidth = true
        digWide = digDeepOrg
        digDeep = -digWideOrg
    end
    
    local blnNegativeHeight = false
    local remainingDigHeight = digHeight
    if digHeight < 0 then
        blnNegativeHeight = true
        remainingDigHeight = -digHeight
    end
    
    -- Enter and go up
    if not blnStartWithin then
        gfPosDig()
        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    else
        tPos[2] = 1
        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    end
    
    if not blnNegativeWidth then
        grPos()
    end
    
    -- Starting height
    if not blnLayerByLayer then
        if digHeight > 2 then
            guPos(digHeight-2)
            moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        elseif digHeight < -1 then 
            gdPos(1)
            moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        end
    else
        if digHeight > 1 then
            guPos(digHeight-1)
            moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        end
    end
    
    -- Main mining loop
    while remainingDigHeight > 0 and isOperationActive and not isPaused do
        -- Set dig up/down
        if not blnLayerByLayer then
            if not blnNegativeHeight then
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
            else
                if tPos[3] >= digHeight + 3 then
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
        else
            blnDigUp = false
            blnDigDown = false
        end
        
        -- Dig one level
        for iy = 1, digDeep, 1 do
            if not isOperationActive or isPaused then break end
            
            if iy == 1 then
                gfPosDig()
                moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            elseif iy % 2 == 0 then
                glPos()
                gfPosDig()
                glPos()
                moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            else 
                grPos()
                gfPosDig()
                grPos()
                moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            end
            
            gfPosDig(digWide-2)
            moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            
            if iy == digDeep then
                if iy % 2 == 1 then
                    glPos(2)
                    gfPosDig(digWide-2)
                end
                gfPosDig()
                glPos()
                gfPosDig(digDeep-1)
                glPos()
                moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            end
        end
        
        -- Change level
        remainingDigHeight = remainingDigHeight - 1
        if blnDigUp then remainingDigHeight = remainingDigHeight - 1 end
        if blnDigDown then remainingDigHeight = remainingDigHeight - 1 end
        
        if remainingDigHeight > 0 then
            if not blnLayerByLayer then
                if not blnNegativeHeight then
                    if remainingDigHeight >= 2 then 
                        gdPos(3)
                        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
                    else
                        gdPos(tPos[3]-1)
                        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
                    end
                else
                    if remainingDigHeight >= 2 then
                        gdPos(3)
                        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
                    else
                        gdPos(-digHeight + tPos[3] - 2)
                        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
                    end
                end
            else
                gdPos(1)
                moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
            end
        end
        
        -- Send periodic status updates
        if os.time() - lastStatusReport >= statusReportInterval then
            sendStatusUpdate()
        end
    end
    
    -- Return to floor
    if not blnNegativeHeight then
        gdPos(tPos[3]-1)
    else
        guPos(-tPos[3]+1)
    end
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    
    if not blnNegativeWidth then
        glPos()
    end
    
    if not blnStartWithin then
        gbPos()
        moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    end
    
    -- Stop chunky turtle
    stopChunkyTurtle()
    
    print("Mining operation completed!")
    
    -- Send completion status
    if controllerId then
        sendMessage(controllerId, {
            type = "operation_complete",
            timestamp = os.time()
        })
    end
end

---------------------------------------
---- Message Processing ---------------
---------------------------------------
local function processMessage(senderId, message)
    if message.type == "discover" then
        -- Respond to discovery request
        sendMessage(senderId, {
            type = "mining_turtle_available",
            name = "Advanced Mining Turtle",
            fuel = turtle.getFuelLevel(),
            inventory = math.floor((turtle.getItemCount() / (16 * 64)) * 100),
            timestamp = os.time()
        })
        return true
        
    elseif message.type == "start_mining" then
        -- Start mining operation
        controllerId = senderId
        chunkyTurtleId = message.chunkyId
        operationCommand = message.command
        isOperationActive = true
        isPaused = false
        
        print("Received mining command: " .. operationCommand)
        print("Controller ID: " .. controllerId)
        if chunkyTurtleId then
            print("Chunky Turtle ID: " .. chunkyTurtleId)
        end
        
        -- Parse and start operation
        parseOperationCommand(operationCommand)
        
        -- Send confirmation
        sendMessage(controllerId, {
            type = "mining_started",
            command = operationCommand,
            timestamp = os.time()
        })
        
        -- Start mining in a separate thread
        local function miningThread()
            local ok, err = pcall(performMiningOperation)
            if not ok then
                print("Mining operation failed: " .. tostring(err))
                if controllerId then
                    sendMessage(controllerId, {
                        type = "operation_error",
                        error = tostring(err),
                        timestamp = os.time()
                    })
                end
            end
        end
        
        -- Start mining thread
        local thread = coroutine.create(miningThread)
        coroutine.resume(thread)
        
        return true
        
    elseif message.type == "status_request" then
        -- Send status update
        sendStatusUpdate()
        return true
        
    elseif message.type == "pause_operation" then
        -- Pause operation
        isPaused = true
        print("Operation paused by controller")
        return true
        
    elseif message.type == "resume_operation" then
        -- Resume operation
        isPaused = false
        print("Operation resumed by controller")
        return true
        
    elseif message.type == "stop_operation" then
        -- Stop operation
        isOperationActive = false
        isPaused = false
        print("Operation stopped by controller")
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
    print("  Advanced Mining Turtle " .. cVersion)
    print("==========================================")
    print()
    
    -- Initialize rednet
    local modemSide = findModem()
    rednet.open(modemSide)
    print("Rednet initialized on " .. modemSide)
    print("Turtle ID: " .. os.getComputerID())
    print()
    print("Waiting for controller commands...")
    print("Press Ctrl+T to exit")
    
    -- Main message loop
    while true do
        local senderId, message, msgProtocol = rednet.receive()
        
        if senderId and msgProtocol == protocol then
            local handled = processMessage(senderId, message)
            if handled then
                debugPrint("Processed message from " .. senderId)
            end
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
