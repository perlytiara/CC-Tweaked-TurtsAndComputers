--{program="simple_deployer",version="1.0",date="2024-12-19"}
---------------------------------------
-- Simple Turtle Deployer             by AI Assistant
-- 2024-12-19, v1.0   Minimal turtle deployment test
---------------------------------------

local cVersion = "v1.0"
local cPrgName = "Simple Deployer"

function debugPrint(message)
    print("[" .. cPrgName .. "] " .. message)
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
    centerText(" SIMPLE DEPLOYER ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function showInventory()
    debugPrint("=== CURRENT INVENTORY ===")
    local hasItems = false
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            debugPrint("Slot " .. slot .. ": " .. item.name .. " x" .. item.count)
            hasItems = true
        end
    end
    if not hasItems then
        debugPrint("Inventory is empty")
    end
    debugPrint("=== END INVENTORY ===")
end

function testLeftChest()
    debugPrint("=== TESTING LEFT CHEST ===")
    
    -- Turn left
    turtle.turnLeft()
    debugPrint("Turned left")
    
    -- Move forward
    local moved = turtle.forward()
    if not moved then
        debugPrint("Cannot move forward - no chest there")
        turtle.turnRight()
        return false
    end
    debugPrint("Moved forward to chest")
    
    -- Check what's in front
    local success, data = turtle.inspect()
    if success then
        debugPrint("Found block: " .. data.name)
        if data.name:match("chest") then
            debugPrint("Confirmed: It's a chest!")
            
            -- Try to suck something
            debugPrint("Attempting to suck 1 item...")
            local sucked = turtle.suck(1)
            if sucked then
                debugPrint("Successfully sucked item!")
                showInventory()
                return true
            else
                debugPrint("Failed to suck item - chest might be empty")
            end
        else
            debugPrint("Not a chest: " .. data.name)
        end
    else
        debugPrint("No block found in front")
    end
    
    -- Move back
    turtle.back()
    debugPrint("Moved back from chest")
    turtle.turnRight()
    debugPrint("Turned back to original direction")
    
    return false
end

function placeTurtle()
    debugPrint("=== ATTEMPTING TO PLACE TURTLE ===")
    
    -- Check if we have a turtle
    local hasTurtle = false
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and (item.name:match("turtle") or item.name:match("computer")) then
            debugPrint("Found turtle in slot " .. slot .. ": " .. item.name)
            hasTurtle = true
            break
        end
    end
    
    if not hasTurtle then
        debugPrint("No turtle found in inventory to place")
        return false
    end
    
    -- Try to place down
    debugPrint("Attempting to place turtle down...")
    local success = turtle.placeDown()
    
    if success then
        debugPrint("Successfully placed turtle down!")
        showInventory()
        return true
    else
        debugPrint("Failed to place turtle down")
        return false
    end
end

function main()
    clearScreen()
    drawHeader()
    
    debugPrint("Starting Simple Deployer Test")
    debugPrint("This will test getting a turtle from left chest and placing it")
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    write("Press any key to start test...")
    os.pullEvent("key")
    
    clearScreen()
    drawHeader()
    
    -- Show initial inventory
    debugPrint("=== INITIAL INVENTORY ===")
    showInventory()
    
    -- Test left chest
    local gotTurtle = testLeftChest()
    
    if gotTurtle then
        debugPrint("Successfully got turtle from left chest!")
        
        clearScreen()
        drawHeader()
        term.setTextColor(colors.green)
        centerText("Got Turtle Successfully!", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Press any key to try placing it...")
        os.pullEvent("key")
        
        -- Try to place it
        local placed = placeTurtle()
        
        if placed then
            clearScreen()
            drawHeader()
            term.setTextColor(colors.green)
            centerText("TURTLE PLACED SUCCESSFULLY!", 5)
            term.setTextColor(colors.white)
        else
            clearScreen()
            drawHeader()
            term.setTextColor(colors.red)
            centerText("Failed to place turtle", 5)
            term.setTextColor(colors.white)
        end
    else
        clearScreen()
        drawHeader()
        term.setTextColor(colors.red)
        centerText("Failed to get turtle", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Check if:")
        term.setCursorPos(2, 8)
        write("1. Left chest exists")
        term.setCursorPos(2, 9)
        write("2. Chest has turtles in it")
        term.setCursorPos(2, 10)
        write("3. Turtle has empty inventory slots")
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to exit...")
    os.pullEvent("key")
    
    clearScreen()
    term.setCursorPos(1, 1)
end

-- Start the simple deployer
main()
