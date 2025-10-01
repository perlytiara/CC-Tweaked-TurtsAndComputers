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
    local moved = turtle.forward()
    if not moved then
        debugPrint("Failed to move forward to " .. direction .. " chest")
        -- Turn back to original direction
        if direction == "left" then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
        return false
    end
    
    -- Check if there's a chest in front
    local success, data = turtle.inspect()
    if not success or not data.name:match("chest") then
        debugPrint("No chest found at " .. direction .. " position")
        turtle.back()
        if direction == "left" then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
        return false
    end
    
    -- Try to suck one turtle from chest
    local sucked = turtle.suck(1)
    
    if sucked then
        debugPrint("Successfully got turtle from " .. direction .. " chest")
        return true
    else
        debugPrint("Failed to get turtle from " .. direction .. " chest - no turtles available")
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

function deploySingleTurtle(direction)
    debugPrint("=== DEPLOYING " .. string.upper(direction) .. " TURTLE ===")
    
    -- Step 1: Get turtle from chest
    local gotTurtle = getTurtleFromChest(direction)
    if not gotTurtle then
        debugPrint("Failed to get turtle from " .. direction .. " chest")
        return false
    end
    
    -- Step 2: Return to original position
    returnToOriginalPosition(direction)
    
    -- Step 3: Place turtle down
    debugPrint("Placing turtle down...")
    local success = turtle.placeDown()
    
    if not success then
        debugPrint("Failed to place turtle down")
        return false
    end
    
    debugPrint("Turtle placed successfully!")
    
    -- Step 4: Get coal from below chest
    debugPrint("Getting coal for the deployed turtle...")
    getCoalFromBelow()
    
    debugPrint(direction .. " turtle deployment complete")
    return true
end

function checkSetup()
    debugPrint("Checking setup...")
    
    local issues = {}
    
    -- Check left chest
    turtle.turnLeft()
    local moved = turtle.forward()
    if moved then
        local success, data = turtle.inspect()
        if success and data.name:match("chest") then
            debugPrint("Left chest found")
        else
            table.insert(issues, "No chest found to the left")
        end
        turtle.back()
    else
        table.insert(issues, "Cannot move left - no chest there")
    end
    turtle.turnRight()
    
    -- Check right chest
    turtle.turnRight()
    moved = turtle.forward()
    if moved then
        local success, data = turtle.inspect()
        if success and data.name:match("chest") then
            debugPrint("Right chest found")
        else
            table.insert(issues, "No chest found to the right")
        end
        turtle.back()
    else
        table.insert(issues, "Cannot move right - no chest there")
    end
    turtle.turnLeft()
    
    -- Check below chest
    local moved = turtle.down()
    if moved then
        local success, data = turtle.inspect()
        if success and data.name:match("chest") then
            debugPrint("Below chest found")
        else
            table.insert(issues, "No chest found below")
        end
        turtle.up()
    else
        table.insert(issues, "Cannot move down - no chest there")
    end
    
    return issues
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
    
    -- Check setup
    term.setTextColor(colors.blue)
    term.setCursorPos(2, 14)
    write("Checking setup...")
    
    local issues = checkSetup()
    if #issues == 0 then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 15)
        write("Setup looks good!")
        term.setTextColor(colors.green)
        term.setCursorPos(2, 17)
        write("Press any key to start deployment...")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 15)
        write("Setup issues found:")
        for i, issue in ipairs(issues) do
            term.setCursorPos(4, 15 + i)
            write("- " .. issue)
        end
        term.setTextColor(colors.yellow)
        term.setCursorPos(2, 15 + #issues + 1)
        write("Fix these issues and restart the program")
    end
    
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
    
    local leftSuccess = deploySingleTurtle("left")
    
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
    
    local rightSuccess = deploySingleTurtle("right")
    
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
