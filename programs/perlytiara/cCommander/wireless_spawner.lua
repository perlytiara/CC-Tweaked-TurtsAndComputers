--{program="wireless_spawner",version="1.0",date="2024-12-19"}
---------------------------------------
-- Wireless Spawner                   by AI Assistant
-- 2024-12-19, v1.0   Spawn turtles and send wireless commands
---------------------------------------

local cVersion = "v1.0"
local cPrgName = "Wireless Spawner"

-- Terminal dimensions
local w, h = term.getSize()

-- Communication settings
local protocol = "turtle-spawner"
local rednetSide = "right" -- Assuming wireless modem on right side

function debugPrint(message)
    print("[" .. cPrgName .. "] " .. message)
end

function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

function centerText(text, y)
    local x = math.floor((w - string.len(text)) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    write(text)
end

function drawHeader()
    term.setTextColor(colors.blue)
    centerText("===================", 1)
    centerText(" WIRELESS SPAWNER ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function initializeRednet()
    debugPrint("Initializing rednet communication...")
    
    if peripheral.find("modem") then
        rednet.open(rednetSide)
        debugPrint("Rednet opened on " .. rednetSide)
        return true
    else
        debugPrint("No wireless modem found!")
        return false
    end
end

function sendCommandToTurtle(turtleId, command)
    debugPrint("Sending command to turtle " .. turtleId .. ": " .. command)
    
    local message = {
        type = "command",
        target = turtleId,
        command = command,
        timestamp = os.epoch("utc")
    }
    
    rednet.broadcast(message, protocol)
    debugPrint("Command broadcasted via rednet")
    
    return true
end

function spawnTurtleViaCommand(x, y, z, facing, turtleType)
    debugPrint("Spawning " .. turtleType .. " turtle at " .. x .. "," .. y .. "," .. z)
    
    -- Use the spawn command (this assumes you have spawn permissions)
    local command = string.format("spawn %s %d %d %d", turtleType, x, y, z)
    
    debugPrint("Executing: " .. command)
    local success = commands.exec(command)
    
    if success then
        debugPrint("Turtle spawned successfully")
        return true
    else
        debugPrint("Failed to spawn turtle - trying alternative method")
        
        -- Alternative: Use summon command
        local summonCmd = string.format("summon minecraft:turtle %d %d %d", x, y, z)
        debugPrint("Trying: " .. summonCmd)
        success = commands.exec(summonCmd)
        
        return success
    end
end

function deployLeftTurtle()
    debugPrint("=== DEPLOYING LEFT TURTLE ===")
    
    -- Spawn position
    local spawnX = -2
    local spawnY = 0
    local spawnZ = 0
    
    -- Spawn the turtle
    local success = spawnTurtleViaCommand(spawnX, spawnY, spawnZ, 0, "MiningTurtle")
    
    if success then
        debugPrint("Left turtle spawned, sending positioning commands...")
        
        -- Send positioning commands via wireless
        local turtleId = "mining_turtle_left"
        sendCommandToTurtle(turtleId, "turn left")
        sleep(0.5)
        sendCommandToTurtle(turtleId, "move forward")
        sleep(0.5)
        sendCommandToTurtle(turtleId, "turn right")
        sleep(0.5)
        
        debugPrint("Left turtle positioned to face center")
        return true
    else
        debugPrint("Failed to spawn left turtle")
        return false
    end
end

function deployRightTurtle()
    debugPrint("=== DEPLOYING RIGHT TURTLE ===")
    
    -- Spawn position
    local spawnX = 2
    local spawnY = 0
    local spawnZ = 0
    
    -- Spawn the turtle
    local success = spawnTurtleViaCommand(spawnX, spawnY, spawnZ, 180, "ChunkyTurtle")
    
    if success then
        debugPrint("Right turtle spawned, sending positioning commands...")
        
        -- Send positioning commands via wireless
        local turtleId = "chunky_turtle_right"
        sendCommandToTurtle(turtleId, "turn right")
        sleep(0.5)
        sendCommandToTurtle(turtleId, "move forward")
        sleep(0.5)
        sendCommandToTurtle(turtleId, "turn left")
        sleep(0.5)
        
        debugPrint("Right turtle positioned to face center")
        return true
    else
        debugPrint("Failed to spawn right turtle")
        return false
    end
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    write("Wireless Spawner v" .. cVersion)
    term.setCursorPos(2, 6)
    write("Spawns turtles and sends wireless commands")
    
    term.setTextColor(colors.yellow)
    term.setCursorPos(2, 8)
    write("Instructions:")
    term.setTextColor(colors.white)
    term.setCursorPos(4, 9)
    write("1. Requires wireless modem on " .. rednetSide .. " side")
    term.setCursorPos(4, 10)
    write("2. Spawns turtles at specific coordinates")
    term.setCursorPos(4, 11)
    write("3. Sends positioning commands via rednet")
    term.setCursorPos(4, 12)
    write("4. Turtles must have wireless modems to receive commands")
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, 14)
    write("Press any key to start...")
    term.setTextColor(colors.white)
    
    os.pullEvent("key")
end

function main()
    debugPrint("Starting " .. cPrgName .. " v" .. cVersion)
    
    showMainMenu()
    
    -- Initialize wireless communication
    if not initializeRednet() then
        clearScreen()
        drawHeader()
        term.setTextColor(colors.red)
        centerText("WIRELESS MODEM REQUIRED", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("This program requires a wireless modem")
        term.setCursorPos(2, 8)
        write("Place a wireless modem on the " .. rednetSide .. " side")
        term.setCursorPos(2, h - 1)
        write("Press any key to exit...")
        os.pullEvent("key")
        return
    end
    
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Starting Wireless Deployment", 5)
    term.setTextColor(colors.white)
    
    -- Deploy left turtle
    clearScreen()
    drawHeader()
    term.setTextColor(colors.blue)
    centerText("Spawning Left Turtle", 5)
    term.setTextColor(colors.white)
    
    local leftSuccess = deployLeftTurtle()
    
    if leftSuccess then
        term.setTextColor(colors.green)
        centerText("Left turtle spawned and positioned!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Left turtle deployment failed!", 7)
    end
    
    term.setCursorPos(2, 9)
    write("Press any key to spawn right turtle...")
    os.pullEvent("key")
    
    -- Deploy right turtle
    clearScreen()
    drawHeader()
    term.setTextColor(colors.blue)
    centerText("Spawning Right Turtle", 5)
    term.setTextColor(colors.white)
    
    local rightSuccess = deployRightTurtle()
    
    if rightSuccess then
        term.setTextColor(colors.green)
        centerText("Right turtle spawned and positioned!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Right turtle deployment failed!", 7)
    end
    
    -- Final status
    clearScreen()
    drawHeader()
    
    if leftSuccess and rightSuccess then
        term.setTextColor(colors.green)
        centerText("WIRELESS DEPLOYMENT COMPLETE!", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Both turtles spawned and positioned")
        term.setCursorPos(2, 8)
        write("Commands sent via wireless communication")
        term.setCursorPos(2, 9)
        write("Turtles should be facing each other")
    else
        term.setTextColor(colors.red)
        centerText("WIRELESS DEPLOYMENT INCOMPLETE", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Left turtle: " .. (leftSuccess and "Success" or "Failed"))
        term.setCursorPos(2, 8)
        write("Right turtle: " .. (rightSuccess and "Success" or "Failed"))
    end
    
    -- Close rednet
    rednet.close()
    debugPrint("Rednet communication closed")
    
    term.setCursorPos(2, h - 1)
    write("Press any key to exit...")
    os.pullEvent("key")
    
    clearScreen()
    term.setCursorPos(1, 1)
end

-- Start the wireless spawner
main()
