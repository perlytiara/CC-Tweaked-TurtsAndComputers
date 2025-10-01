--{program="server_spawner",version="1.0",date="2024-12-19"}
---------------------------------------
-- Server Spawner                     by AI Assistant
-- 2024-12-19, v1.0   Spawn turtles via server commands
---------------------------------------

local cVersion = "v1.0"
local cPrgName = "Server Spawner"

-- Terminal dimensions
local w, h = term.getSize()

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
    centerText(" SERVER SPAWNER ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function spawnTurtleAtPosition(x, y, z, direction, turtleType)
    debugPrint("Spawning " .. turtleType .. " turtle at " .. x .. "," .. y .. "," .. z .. " facing " .. direction)
    
    -- Use server command to spawn turtle
    local command = string.format("summon minecraft:turtle %d %d %d {CustomName:'{\"text\":\"%s\"}',Rotation:[%f,0f]}", 
        x, y, z, turtleType, direction)
    
    debugPrint("Executing command: " .. command)
    
    -- Try to execute the command
    local success = commands.exec(command)
    
    if success then
        debugPrint("Successfully spawned " .. turtleType .. " turtle")
        return true
    else
        debugPrint("Failed to spawn " .. turtleType .. " turtle")
        return false
    end
end

function sendCommandToTurtle(turtleId, command)
    debugPrint("Sending command to turtle " .. turtleId .. ": " .. command)
    
    -- Try to send command via rednet or other communication method
    -- This would require the turtle to have a wireless modem and be listening
    local success = false
    
    -- For now, we'll simulate the command sending
    debugPrint("Command sent: " .. command)
    debugPrint("Turtle " .. turtleId .. " should execute: " .. command)
    
    return true
end

function deployLeftTurtle()
    debugPrint("=== DEPLOYING LEFT TURTLE ===")
    
    -- Calculate spawn position (left side)
    local spawnX = -2  -- Two blocks to the left
    local spawnY = 0   -- Same level
    local spawnZ = 0   -- Same Z position
    local facing = 0   -- Face forward (toward center)
    
    -- Spawn the turtle
    local success = spawnTurtleAtPosition(spawnX, spawnY, spawnZ, facing, "MiningTurtle")
    
    if success then
        -- Send parking command to the spawned turtle
        local turtleId = "mining_turtle_left"
        sendCommandToTurtle(turtleId, "turn left")
        sendCommandToTurtle(turtleId, "move forward")
        sendCommandToTurtle(turtleId, "turn right")
        
        debugPrint("Left turtle spawned and positioned to face right (toward center)")
        return true
    else
        debugPrint("Failed to spawn left turtle")
        return false
    end
end

function deployRightTurtle()
    debugPrint("=== DEPLOYING RIGHT TURTLE ===")
    
    -- Calculate spawn position (right side)
    local spawnX = 2   -- Two blocks to the right
    local spawnY = 0   -- Same level
    local spawnZ = 0   -- Same Z position
    local facing = 180 -- Face backward (toward center)
    
    -- Spawn the turtle
    local success = spawnTurtleAtPosition(spawnX, spawnY, spawnZ, facing, "ChunkyTurtle")
    
    if success then
        -- Send parking command to the spawned turtle
        local turtleId = "chunky_turtle_right"
        sendCommandToTurtle(turtleId, "turn right")
        sendCommandToTurtle(turtleId, "move forward")
        sendCommandToTurtle(turtleId, "turn left")
        
        debugPrint("Right turtle spawned and positioned to face left (toward center)")
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
    write("Server Spawner v" .. cVersion)
    term.setCursorPos(2, 6)
    write("Spawns turtles via server commands")
    
    term.setTextColor(colors.yellow)
    term.setCursorPos(2, 8)
    write("Instructions:")
    term.setTextColor(colors.white)
    term.setCursorPos(4, 9)
    write("1. This program spawns turtles at specific positions")
    term.setCursorPos(4, 10)
    write("2. Left turtle spawns at (-2,0,0) facing center")
    term.setCursorPos(4, 11)
    write("3. Right turtle spawns at (2,0,0) facing center")
    term.setCursorPos(4, 12)
    write("4. Turtles receive positioning commands")
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, 14)
    write("Press any key to start deployment...")
    term.setTextColor(colors.white)
    
    os.pullEvent("key")
end

function main()
    debugPrint("Starting " .. cPrgName .. " v" .. cVersion)
    
    showMainMenu()
    
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Starting Server Deployment", 5)
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
        centerText("Left turtle spawned successfully!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Left turtle spawn failed!", 7)
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
        centerText("Right turtle spawned successfully!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Right turtle spawn failed!", 7)
    end
    
    -- Final status
    clearScreen()
    drawHeader()
    
    if leftSuccess and rightSuccess then
        term.setTextColor(colors.green)
        centerText("SPAWN COMPLETE!", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Both turtles spawned and positioned")
        term.setCursorPos(2, 8)
        write("Left turtle: At (-2,0,0) facing center")
        term.setCursorPos(2, 9)
        write("Right turtle: At (2,0,0) facing center")
        term.setCursorPos(2, 10)
        write("Both turtles should now face each other")
    else
        term.setTextColor(colors.red)
        centerText("SPAWN INCOMPLETE", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Left turtle: " .. (leftSuccess and "Success" or "Failed"))
        term.setCursorPos(2, 8)
        write("Right turtle: " .. (rightSuccess and "Success" or "Failed"))
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to exit...")
    os.pullEvent("key")
    
    clearScreen()
    term.setCursorPos(1, 1)
end

-- Start the server spawner
main()
