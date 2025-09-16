--{program="AdvancedMiningController",version="2.0",date="2024-12-19"}
---------------------------------------
-- Advanced Mining Controller         by AI Assistant
-- 2024-12-19, v2.0   Advanced wireless mining system
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Master controller for advanced wireless mining operations
-- Controls mining turtle and chunky turtle from a computer
-- Features automatic pairing, real-time monitoring, and advanced coordination
-- Supports single and multi-turtle operations with chunky pairing

---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Requires a computer with wireless modem
-- Mining turtle placed at left corner of mining area
-- Chunky turtle placed one block to the right of mining turtle
-- Both turtles have wireless modems and required programs

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v2.0"
local cPrgName = "AdvancedMiningController"
local blnDebugPrint = true

-- Communication settings
local protocol = "advanced-mining"
local discoveryTimeout = 5
local responseTimeout = 3

-- Turtle management
local miningTurtleId = nil
local chunkyTurtleId = nil
local isOperationActive = false
local operationStatus = "idle"

-- Operation parameters
local operationParams = {
    depth = 0,
    width = 0,
    height = 0,
    options = {}
}

---------------------------------------
---- Utility Functions ----------------
---------------------------------------
local function debugPrint(str)
    if blnDebugPrint then
        print("[Controller] " .. str)
    end
end

local function findModem()
    for _, p in pairs(rs.getSides()) do
        if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
            return p
        end
    end
    error("No modem attached to this computer.")
end

local function sendMessage(targetId, message, customProtocol)
    local protocolToUse = customProtocol or protocol
    rednet.send(targetId, message, protocolToUse)
    debugPrint("Sent to " .. targetId .. ": " .. textutils.serialize(message))
end

local function broadcastMessage(message, customProtocol)
    local protocolToUse = customProtocol or protocol
    rednet.broadcast(message, protocolToUse)
    debugPrint("Broadcasted: " .. textutils.serialize(message))
end

local function waitForResponse(targetId, expectedType, timeout)
    timeout = timeout or responseTimeout
    local startTime = os.time()
    
    while (os.time() - startTime) < timeout do
        local senderId, message, msgProtocol = rednet.receive(0.1)
        if senderId == targetId and msgProtocol == protocol then
            if message.type == expectedType then
                return message
            end
        end
    end
    return nil
end

---------------------------------------
---- Discovery Functions --------------
---------------------------------------
local function discoverTurtles()
    print("Discovering available turtles...")
    
    -- Send discovery broadcast
    broadcastMessage({
        type = "discover",
        controllerId = os.getComputerID(),
        timestamp = os.time()
    })
    
    local discoveredTurtles = {}
    local discoveredChunkies = {}
    local startTime = os.time()
    
    -- Collect responses
    while (os.time() - startTime) < discoveryTimeout do
        local senderId, message, msgProtocol = rednet.receive(0.1)
        if senderId and msgProtocol == protocol then
            if message.type == "mining_turtle_available" then
                table.insert(discoveredTurtles, {
                    id = senderId,
                    name = message.name or "Mining Turtle",
                    fuel = message.fuel or 0,
                    inventory = message.inventory or 0
                })
                print("Found mining turtle: " .. senderId .. " (Fuel: " .. (message.fuel or 0) .. ")")
            elseif message.type == "chunky_turtle_available" then
                table.insert(discoveredChunkies, {
                    id = senderId,
                    name = message.name or "Chunky Turtle",
                    fuel = message.fuel or 0
                })
                print("Found chunky turtle: " .. senderId .. " (Fuel: " .. (message.fuel or 0) .. ")")
            end
        end
    end
    
    return discoveredTurtles, discoveredChunkies
end

local function selectTurtles(discoveredTurtles, discoveredChunkies)
    print("\n=== Turtle Selection ===")
    
    -- Select mining turtle
    if #discoveredTurtles == 0 then
        error("No mining turtles found! Make sure mining turtle is running AdvancedMiningTurtle.lua")
    end
    
    if #discoveredTurtles == 1 then
        miningTurtleId = discoveredTurtles[1].id
        print("Auto-selected mining turtle: " .. miningTurtleId)
    else
        print("Multiple mining turtles found:")
        for i, turtle in ipairs(discoveredTurtles) do
            print(i .. ". ID: " .. turtle.id .. " - Fuel: " .. turtle.fuel .. " - Inventory: " .. turtle.inventory .. "%")
        end
        print("Select mining turtle (1-" .. #discoveredTurtles .. "):")
        local choice = tonumber(read())
        if choice and choice >= 1 and choice <= #discoveredTurtles then
            miningTurtleId = discoveredTurtles[choice].id
        else
            error("Invalid selection")
        end
    end
    
    -- Select chunky turtle
    if #discoveredChunkies == 0 then
        print("No chunky turtles found. Operation will continue without chunky pairing.")
        chunkyTurtleId = nil
    elseif #discoveredChunkies == 1 then
        chunkyTurtleId = discoveredChunkies[1].id
        print("Auto-selected chunky turtle: " .. chunkyTurtleId)
    else
        print("Multiple chunky turtles found:")
        for i, chunky in ipairs(discoveredChunkies) do
            print(i .. ". ID: " .. chunky.id .. " - Fuel: " .. chunky.fuel)
        end
        print("Select chunky turtle (1-" .. #discoveredChunkies .. ", or 0 to skip):")
        local choice = tonumber(read())
        if choice and choice >= 1 and choice <= #discoveredChunkies then
            chunkyTurtleId = discoveredChunkies[choice].id
        elseif choice == 0 then
            chunkyTurtleId = nil
            print("Skipping chunky turtle pairing")
        else
            error("Invalid selection")
        end
    end
end

---------------------------------------
---- Operation Functions --------------
---------------------------------------
local function getOperationParameters()
    print("\n=== Operation Parameters ===")
    
    print("Enter mining depth (forward distance, >= 1):")
    operationParams.depth = tonumber(read())
    if not operationParams.depth or operationParams.depth < 1 then
        error("Invalid depth. Must be >= 1")
    end
    
    print("Enter mining width (side distance, cannot be -1, 0, or 1):")
    operationParams.width = tonumber(read())
    if not operationParams.width or operationParams.width == -1 or operationParams.width == 0 or operationParams.width == 1 then
        error("Invalid width. Cannot be -1, 0, or 1")
    end
    
    print("Enter mining height (up/down distance, cannot be 0):")
    operationParams.height = tonumber(read())
    if not operationParams.height or operationParams.height == 0 then
        error("Invalid height. Cannot be 0")
    end
    
    print("Enter options (space-separated, or press Enter for none):")
    print("Available options: layerbylayer, startwithin, stripmine")
    local optionsInput = read()
    operationParams.options = {}
    if optionsInput and optionsInput ~= "" then
        for option in string.gmatch(optionsInput, "%S+") do
            table.insert(operationParams.options, string.lower(option))
        end
    end
end

local function startOperation()
    print("\n=== Starting Operation ===")
    
    -- Build command string
    local command = tostring(operationParams.depth) .. " " .. 
                   tostring(operationParams.width) .. " " .. 
                   tostring(operationParams.height)
    
    if #operationParams.options > 0 then
        command = command .. " " .. table.concat(operationParams.options, " ")
    end
    
    print("Command: " .. command)
    
    -- Start chunky turtle first if available
    if chunkyTurtleId then
        print("Starting chunky turtle...")
        sendMessage(chunkyTurtleId, {
            type = "start_chunky",
            masterId = miningTurtleId,
            timestamp = os.time()
        })
        
        -- Wait for chunky turtle to be ready
        local response = waitForResponse(chunkyTurtleId, "chunky_ready", 5)
        if response then
            print("Chunky turtle ready!")
        else
            print("Warning: Chunky turtle did not respond, continuing anyway...")
        end
    end
    
    -- Start mining turtle
    print("Starting mining turtle...")
    sendMessage(miningTurtleId, {
        type = "start_mining",
        command = command,
        chunkyId = chunkyTurtleId,
        timestamp = os.time()
    })
    
    -- Wait for mining turtle to start
    local response = waitForResponse(miningTurtleId, "mining_started", 5)
    if response then
        print("Mining operation started!")
        isOperationActive = true
        operationStatus = "running"
    else
        error("Mining turtle failed to start operation")
    end
end

---------------------------------------
---- Monitoring Functions -------------
---------------------------------------
local function monitorOperation()
    print("\n=== Operation Monitoring ===")
    print("Press 's' for status, 'p' to pause, 'r' to resume, 'q' to quit monitoring")
    
    while isOperationActive do
        local event, key = os.pullEvent("key")
        
        if key == keys.s then
            -- Request status update
            sendMessage(miningTurtleId, {
                type = "status_request",
                timestamp = os.time()
            })
            
            local statusResponse = waitForResponse(miningTurtleId, "status_update", 2)
            if statusResponse then
                print("=== Status Update ===")
                print("Position: " .. (statusResponse.position or "unknown"))
                print("Progress: " .. (statusResponse.progress or "unknown"))
                print("Fuel: " .. (statusResponse.fuel or "unknown"))
                print("Inventory: " .. (statusResponse.inventory or "unknown"))
                if statusResponse.chunkyStatus then
                    print("Chunky Status: " .. statusResponse.chunkyStatus)
                end
            else
                print("No status response received")
            end
            
        elseif key == keys.p then
            -- Pause operation
            sendMessage(miningTurtleId, {
                type = "pause_operation",
                timestamp = os.time()
            })
            print("Pause command sent")
            
        elseif key == keys.r then
            -- Resume operation
            sendMessage(miningTurtleId, {
                type = "resume_operation",
                timestamp = os.time()
            })
            print("Resume command sent")
            
        elseif key == keys.q then
            -- Quit monitoring (but don't stop operation)
            print("Stopping monitoring. Operation continues...")
            break
        end
    end
end

local function stopOperation()
    print("\n=== Stopping Operation ===")
    
    if isOperationActive then
        -- Stop mining turtle
        sendMessage(miningTurtleId, {
            type = "stop_operation",
            timestamp = os.time()
        })
        
        -- Stop chunky turtle if active
        if chunkyTurtleId then
            sendMessage(chunkyTurtleId, {
                type = "stop_operation",
                timestamp = os.time()
            })
        end
        
        isOperationActive = false
        operationStatus = "stopped"
        print("Stop commands sent to all turtles")
    end
end

---------------------------------------
---- Main Program ----------------------
---------------------------------------
local function main()
    term.clear()
    term.setCursorPos(1, 1)
    
    print("==========================================")
    print("  Advanced Mining Controller " .. cVersion)
    print("==========================================")
    print()
    
    -- Initialize rednet
    local modemSide = findModem()
    rednet.open(modemSide)
    print("Rednet initialized on " .. modemSide)
    
    -- Discover turtles
    local discoveredTurtles, discoveredChunkies = discoverTurtles()
    
    if #discoveredTurtles == 0 then
        error("No mining turtles found! Make sure at least one mining turtle is running AdvancedMiningTurtle.lua")
    end
    
    -- Select turtles
    selectTurtles(discoveredTurtles, discoveredChunkies)
    
    -- Get operation parameters
    getOperationParameters()
    
    -- Confirm operation
    print("\n=== Operation Summary ===")
    print("Mining Turtle: " .. miningTurtleId)
    print("Chunky Turtle: " .. (chunkyTurtleId or "None"))
    print("Parameters: " .. operationParams.depth .. " x " .. operationParams.width .. " x " .. operationParams.height)
    if #operationParams.options > 0 then
        print("Options: " .. table.concat(operationParams.options, ", "))
    end
    print()
    print("Start operation? (y/n):")
    local confirm = read()
    
    if string.lower(confirm) == "y" or string.lower(confirm) == "yes" then
        startOperation()
        
        -- Monitor operation
        monitorOperation()
        
        -- Final stop
        stopOperation()
    else
        print("Operation cancelled")
    end
    
    print("\nAdvanced Mining Controller finished.")
end

-- Run main program
local ok, err = pcall(main)
if not ok then
    print("Error: " .. tostring(err))
    print("Press any key to exit...")
    os.pullEvent("key")
end
