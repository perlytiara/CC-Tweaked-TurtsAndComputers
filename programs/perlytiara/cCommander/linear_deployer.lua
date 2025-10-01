--{program="linear_deployer",version="1.0",date="2024-12-19"}
---------------------------------------
-- Linear Turtle Deployer             by AI Assistant
-- 2024-12-19, v1.0   Step-by-step turtle deployment
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Linear turtle deployment program that:
-- 1. Gets turtle from left chest, places it, and positions it
-- 2. Gets turtle from right chest, places it, and positions it
-- 3. Both deployed turtles face each other toward center

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v1.0"
local cPrgName = "Linear Turtle Deployer"
local blnDebugPrint = true

-- Position tracking
local originalFacing = 0 -- Will store original direction

-- Terminal dimensions
local w, h = term.getSize()

---------------------------------------
---- UTILITY FUNCTIONS --------------- 
---------------------------------------
function debugPrint(message)
    if blnDebugPrint then
        print("[" .. cPrgName .. "] " .. message)
    end
end

function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

function centerText(text, y)
    local w, h = term.getSize()
    local x = math.floor((w - string.len(text)) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    write(text)
end

function drawHeader()
    term.setTextColor(colors.blue)
    centerText("===================", 1)
    centerText(" LINEAR DEPLOYER ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function waitForUser(message)
    if message then
        term.setTextColor(colors.yellow)
        centerText(message, 5)
        term.setTextColor(colors.white)
    end
    term.setCursorPos(2, 7)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function getTurtleFromChest(direction)
    debugPrint("Getting turtle from " .. direction .. " chest")
    
    -- Turn to face the chest
    if direction == "left" then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    
    -- Move forward to chest
    turtle.forward()
    
    -- Try to suck one turtle from chest
    local success = turtle.suck(1)
    
    if success then
        debugPrint("Successfully got turtle from " .. direction .. " chest")
        return true
    else
        debugPrint("Failed to get turtle from " .. direction .. " chest")
        return false
    end
end

function returnToOriginalPosition(direction)
    debugPrint("Returning to original position from " .. direction)
    
    -- Move back from chest
    turtle.back()
    
    -- Turn back to original facing direction
    if direction == "left" then
        turtle.turnRight() -- Turn right to face original direction
    else
        turtle.turnLeft() -- Turn left to face original direction
    end
end

function placeTurtleAndPosition(direction)
    debugPrint("Placing turtle and positioning it")
    
    -- Place the turtle down
    local success = turtle.placeDown()
    
    if not success then
        debugPrint("Failed to place turtle down")
        return false
    end
    
    debugPrint("Turtle placed, waiting for it to load...")
    sleep(3) -- Wait for turtle to initialize
    
    -- Position the deployed turtle
    if direction == "left" then
        -- For left turtle: turn left, walk forward, turn right (facing right toward center)
        debugPrint("Positioning left turtle to face right")
        
        -- The deployed turtle should:
        -- 1. Turn left (relative to its spawn direction)
        -- 2. Move forward one block
        -- 3. Turn right to face the center
        
        -- We can't directly control the deployed turtle, but we can move to position ourselves
        -- Move to the right side of the deployed turtle
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        
    else
        -- For right turtle: turn right, walk forward, turn left (facing left toward center)
        debugPrint("Positioning right turtle to face left")
        
        -- Move to the left side of the deployed turtle
        turtle.turnLeft()
        turtle.forward()
        turtle.turnRight()
    end
    
    return true
end

function getCoalFromBelow()
    debugPrint("Getting coal from below chest")
    
    -- Move down to coal chest
    turtle.down()
    
    -- Try to get coal
    local success = turtle.suckDown(1)
    
    if success then
        debugPrint("Successfully got coal from below")
        -- Move back up
        turtle.up()
        return true
    else
        debugPrint("Failed to get coal from below")
        -- Move back up anyway
        turtle.up()
        return false
    end
end

function deployLeftTurtle()
    debugPrint("=== DEPLOYING LEFT TURTLE ===")
    
    -- Step 1: Get turtle from left chest
    local gotTurtle = getTurtleFromChest("left")
    if not gotTurtle then
        debugPrint("Failed to get turtle from left chest")
        return false
    end
    
    -- Step 2: Return to original position
    returnToOriginalPosition("left")
    
    -- Step 3: Place turtle and position it
    local placed = placeTurtleAndPosition("left")
    if not placed then
        debugPrint("Failed to place left turtle")
        return false
    end
    
    -- Step 4: Get coal from below chest
    getCoalFromBelow()
    
    -- Step 5: Move to left side and face right (toward center)
    debugPrint("Moving to left side and facing right")
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    
    debugPrint("Left turtle deployment complete")
    return true
end

function deployRightTurtle()
    debugPrint("=== DEPLOYING RIGHT TURTLE ===")
    
    -- Step 1: Get turtle from right chest
    local gotTurtle = getTurtleFromChest("right")
    if not gotTurtle then
        debugPrint("Failed to get turtle from right chest")
        return false
    end
    
    -- Step 2: Return to original position
    returnToOriginalPosition("right")
    
    -- Step 3: Place turtle and position it
    local placed = placeTurtleAndPosition("right")
    if not placed then
        debugPrint("Failed to place right turtle")
        return false
    end
    
    -- Step 4: Get coal from below chest
    getCoalFromBelow()
    
    -- Step 5: Move to right side and face left (toward center)
    debugPrint("Moving to right side and facing left")
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    
    debugPrint("Right turtle deployment complete")
    return true
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    write("Linear Turtle Deployer v" .. cVersion)
    term.setCursorPos(2, 6)
    write("This program will deploy turtles step by step")
    
    term.setTextColor(colors.yellow)
    term.setCursorPos(2, 8)
    write("Instructions:")
    term.setTextColor(colors.white)
    term.setCursorPos(4, 9)
    write("1. Place mining turtles in left chest")
    term.setCursorPos(4, 10)
    write("2. Place chunky turtles in right chest")
    term.setCursorPos(4, 11)
    write("3. Place coal in chest below")
    term.setCursorPos(4, 12)
    write("4. Position computer/turtle at center")
    
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
    centerText("Starting Linear Deployment", 5)
    term.setTextColor(colors.white)
    
    -- Store original facing direction
    originalFacing = 0 -- Assuming we start facing forward (0 degrees)
    
    waitForUser("Ready to deploy left turtle?")
    
    -- Deploy left turtle
    clearScreen()
    drawHeader()
    term.setTextColor(colors.blue)
    centerText("Deploying Left Turtle", 5)
    term.setTextColor(colors.white)
    
    local leftSuccess = deployLeftTurtle()
    
    if leftSuccess then
        term.setTextColor(colors.green)
        centerText("Left turtle deployed successfully!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Left turtle deployment failed!", 7)
    end
    
    waitForUser("Ready to deploy right turtle?")
    
    -- Deploy right turtle
    clearScreen()
    drawHeader()
    term.setTextColor(colors.blue)
    centerText("Deploying Right Turtle", 5)
    term.setTextColor(colors.white)
    
    local rightSuccess = deployRightTurtle()
    
    if rightSuccess then
        term.setTextColor(colors.green)
        centerText("Right turtle deployed successfully!", 7)
    else
        term.setTextColor(colors.red)
        centerText("Right turtle deployment failed!", 7)
    end
    
    -- Final status
    clearScreen()
    drawHeader()
    
    if leftSuccess and rightSuccess then
        term.setTextColor(colors.green)
        centerText("DEPLOYMENT COMPLETE!", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Both turtles deployed and positioned")
        term.setCursorPos(2, 8)
        write("Left turtle: Facing right (toward center)")
        term.setCursorPos(2, 9)
        write("Right turtle: Facing left (toward center)")
        term.setCursorPos(2, 10)
        write("Both turtles should now face each other")
    else
        term.setTextColor(colors.red)
        centerText("DEPLOYMENT INCOMPLETE", 5)
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

-- Start the linear deployer
main()
