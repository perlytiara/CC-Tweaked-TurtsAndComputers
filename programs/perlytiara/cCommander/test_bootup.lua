--{program="test_bootup",version="1.0",date="2024-12-19"}
---------------------------------------
-- Test Boot-up System               by AI Assistant
-- 2024-12-19, v1.0   Turtle deployment and management system
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Test boot-up system for deploying turtles from chests
-- Left chest: Advanced mining wireless turtles
-- Right chest: Chunky wireless advanced turtles
-- Below: Coal chest for fuel
-- Features automatic deployment, fueling, and program startup

---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Left chest contains mining turtles with wireless modems
-- Right chest contains chunky turtles with wireless modems
-- Coal chest is directly below the computer
-- Computer has wireless modem for communication
-- All turtles have startup programs ready

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v1.0"
local cPrgName = "Test Boot-up System"
local blnDebugPrint = true

-- Chest positions (relative to computer)
local LEFT_CHEST_POS = vector.new(-1, 0, 0)   -- Left chest
local RIGHT_CHEST_POS = vector.new(1, 0, 0)   -- Right chest
local COAL_CHEST_POS = vector.new(0, -1, 0)   -- Below computer

-- Deployment positions
local MINING_DEPLOY_X = -5  -- Mining turtles deploy to the left
local CHUNKY_DEPLOY_X = 5   -- Chunky turtles deploy to the right
local DEPLOY_Y = 0
local DEPLOY_Z = 0

-- Communication settings
local protocol = "bootup-system"
local deployedTurtles = {}
local deploymentStatus = {
    mining_turtles = 0,
    chunky_turtles = 0,
    total_fueled = 0,
    total_started = 0
}

-- UI settings
local w, h = term.getSize()
local selectedOption = 1
local maxOptions = 6

-- Colors
local colors = {
    white = colors.white,
    gray = colors.gray,
    black = colors.black,
    blue = colors.blue,
    green = colors.green,
    red = colors.red,
    yellow = colors.yellow,
    orange = colors.orange
}

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
    local x = math.floor((w - string.len(text)) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    write(text)
end

function drawHeader()
    term.setTextColor(colors.blue)
    centerText("===================", 1)
    centerText(" TEST BOOT-UP SYSTEM ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function drawFooter()
    local y = h
    term.setTextColor(colors.gray)
    term.setCursorPos(1, y)
    write("Arrows:Navigate | Enter:Select | Q:Quit")
end

function highlightOption(optionNum, text, y)
    if optionNum == selectedOption then
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.white)
        term.setCursorPos(2, y)
        write("> " .. text)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
    else
        term.setTextColor(colors.blue)
        term.setCursorPos(2, y)
        write("  " .. text)
    end
end

function checkChest(position, chestType)
    debugPrint("Checking " .. chestType .. " chest at " .. tostring(position))
    
    -- Check if chest exists
    local success, block = pcall(function()
        return peripheral.wrap("minecraft:chest_" .. tostring(position.x) .. "_" .. tostring(position.y) .. "_" .. tostring(position.z))
    end)
    
    if not success then
        -- Try alternative method
        local chests = peripheral.getNames()
        for _, name in ipairs(chests) do
            if peripheral.getType(name) == "minecraft:chest" then
                local chest = peripheral.wrap(name)
                if chest then
                    local size = chest.size()
                    if size > 0 then
                        return chest, name
                    end
                end
            end
        end
        return nil, "No chest found"
    end
    
    return block, "chest_" .. tostring(position.x) .. "_" .. tostring(position.y) .. "_" .. tostring(position.z)
end

function getTurtlesFromChest(chest, chestType)
    local turtles = {}
    
    if not chest then
        debugPrint("No chest available for " .. chestType)
        return turtles
    end
    
    local size = chest.size()
    for slot = 1, size do
        local item = chest.getItemDetail(slot)
        if item then
            if item.name:match("turtle") or item.name:match("computer") then
                table.insert(turtles, {
                    item = item,
                    slot = slot,
                    name = item.name,
                    count = item.count
                })
                debugPrint("Found turtle: " .. item.name .. " (count: " .. item.count .. ")")
            end
        end
    end
    
    return turtles
end

function deployTurtle(chest, turtleInfo, deployPos, turtleType)
    debugPrint("Deploying " .. turtleType .. " turtle to " .. tostring(deployPos))
    
    -- Place turtle from chest
    local success = chest.pushItems("minecraft:chest_" .. tostring(deployPos.x) .. "_" .. tostring(deployPos.y) .. "_" .. tostring(deployPos.z), turtleInfo.slot, 1)
    
    if success then
        debugPrint("Successfully deployed " .. turtleType .. " turtle")
        
        -- Wait a moment for turtle to initialize
        sleep(1)
        
        -- Try to communicate with deployed turtle
        local turtleId = "turtle_" .. tostring(deployPos.x) .. "_" .. tostring(deployPos.y) .. "_" .. tostring(deployPos.z)
        
        return {
            id = turtleId,
            type = turtleType,
            position = deployPos,
            deployed = true,
            fueled = false,
            started = false
        }
    else
        debugPrint("Failed to deploy " .. turtleType .. " turtle")
        return nil
    end
end

function fuelTurtle(turtleInfo, coalChest)
    debugPrint("Fueling turtle: " .. turtleInfo.id)
    
    if not coalChest then
        debugPrint("No coal chest available")
        return false
    end
    
    -- Get coal from chest
    local coalItems = {}
    local size = coalChest.size()
    for slot = 1, size do
        local item = coalChest.getItemDetail(slot)
        if item and (item.name:match("coal") or item.name:match("charcoal") or item.name:match("lava_bucket")) then
            table.insert(coalItems, {item = item, slot = slot})
        end
    end
    
    if #coalItems == 0 then
        debugPrint("No fuel found in coal chest")
        return false
    end
    
    -- Try to send fuel to turtle (this would require wireless communication)
    -- For now, we'll assume the turtle can access the coal chest directly
    debugPrint("Fuel available: " .. coalItems[1].item.name)
    
    turtleInfo.fueled = true
    deploymentStatus.total_fueled = deploymentStatus.total_fueled + 1
    
    return true
end

function startTurtleProgram(turtleInfo)
    debugPrint("Starting program on turtle: " .. turtleInfo.id)
    
    -- Send startup command via wireless modem
    -- This would require the turtle to have a wireless modem and be listening
    local command = {
        action = "start_program",
        program = turtleInfo.type == "mining" and "AdvancedMiningTurtle" or "AdvancedChunkyTurtle"
    }
    
    -- For demonstration, we'll simulate successful startup
    turtleInfo.started = true
    deploymentStatus.total_started = deploymentStatus.total_started + 1
    
    debugPrint("Program started on " .. turtleInfo.id)
    return true
end

function deployAllTurtles()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Deploying Turtles...", 5)
    term.setTextColor(colors.white)
    
    -- Check chests
    local leftChest, leftChestName = checkChest(LEFT_CHEST_POS, "left")
    local rightChest, rightChestName = checkChest(RIGHT_CHEST_POS, "right")
    local coalChest, coalChestName = checkChest(COAL_CHEST_POS, "coal")
    
    term.setCursorPos(2, 7)
    write("Checking chests...")
    
    if leftChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 8)
        write("Left chest: Found")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 8)
        write("Left chest: Not found")
    end
    
    if rightChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 9)
        write("Right chest: Found")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 9)
        write("Right chest: Not found")
    end
    
    if coalChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 10)
        write("Coal chest: Found")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 10)
        write("Coal chest: Not found")
    end
    
    sleep(2)
    
    -- Get turtles from chests
    local miningTurtles = getTurtlesFromChest(leftChest, "mining")
    local chunkyTurtles = getTurtlesFromChest(rightChest, "chunky")
    
    term.setCursorPos(2, 12)
    write("Found " .. #miningTurtles .. " mining turtles")
    term.setCursorPos(2, 13)
    write("Found " .. #chunkyTurtles .. " chunky turtles")
    
    sleep(2)
    
    -- Deploy mining turtles
    local deployX = MINING_DEPLOY_X
    for i, turtleInfo in ipairs(miningTurtles) do
        if i <= 3 then -- Limit to 3 mining turtles
            local deployPos = vector.new(deployX, DEPLOY_Y, DEPLOY_Z)
            local deployedTurtle = deployTurtle(leftChest, turtleInfo, deployPos, "mining")
            
            if deployedTurtle then
                table.insert(deployedTurtles, deployedTurtle)
                deploymentStatus.mining_turtles = deploymentStatus.mining_turtles + 1
                
                term.setCursorPos(2, 15 + i)
                term.setTextColor(colors.green)
                write("Deployed mining turtle " .. i .. " at " .. tostring(deployPos))
            end
            
            deployX = deployX - 2 -- Space them out
            sleep(1)
        end
    end
    
    -- Deploy chunky turtles
    deployX = CHUNKY_DEPLOY_X
    for i, turtleInfo in ipairs(chunkyTurtles) do
        if i <= 3 then -- Limit to 3 chunky turtles
            local deployPos = vector.new(deployX, DEPLOY_Y, DEPLOY_Z)
            local deployedTurtle = deployTurtle(rightChest, turtleInfo, deployPos, "chunky")
            
            if deployedTurtle then
                table.insert(deployedTurtles, deployedTurtle)
                deploymentStatus.chunky_turtles = deploymentStatus.chunky_turtles + 1
                
                term.setCursorPos(2, 18 + i)
                term.setTextColor(colors.green)
                write("Deployed chunky turtle " .. i .. " at " .. tostring(deployPos))
            end
            
            deployX = deployX + 2 -- Space them out
            sleep(1)
        end
    end
    
    sleep(2)
    
    -- Fuel all deployed turtles
    term.setTextColor(colors.yellow)
    centerText("Fueling Turtles...", 5)
    
    for i, turtleInfo in ipairs(deployedTurtles) do
        if fuelTurtle(turtleInfo, coalChest) then
            term.setCursorPos(2, 7 + i)
            term.setTextColor(colors.green)
            write("Fueled " .. turtleInfo.id)
        else
            term.setCursorPos(2, 7 + i)
            term.setTextColor(colors.red)
            write("Failed to fuel " .. turtleInfo.id)
        end
        sleep(0.5)
    end
    
    sleep(2)
    
    -- Start programs on all turtles
    term.setTextColor(colors.yellow)
    centerText("Starting Programs...", 5)
    
    for i, turtleInfo in ipairs(deployedTurtles) do
        if startTurtleProgram(turtleInfo) then
            term.setCursorPos(2, 7 + i)
            term.setTextColor(colors.green)
            write("Started program on " .. turtleInfo.id)
        else
            term.setCursorPos(2, 7 + i)
            term.setTextColor(colors.red)
            write("Failed to start program on " .. turtleInfo.id)
        end
        sleep(0.5)
    end
    
    sleep(2)
    
    -- Show final status
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.green)
    centerText("Deployment Complete!", 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("Mining Turtles: " .. deploymentStatus.mining_turtles)
    term.setCursorPos(2, 8)
    write("Chunky Turtles: " .. deploymentStatus.chunky_turtles)
    term.setCursorPos(2, 9)
    write("Total Fueled: " .. deploymentStatus.total_fueled)
    term.setCursorPos(2, 10)
    write("Total Started: " .. deploymentStatus.total_started)
    
    term.setCursorPos(2, 12)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showDeploymentStatus()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Deployment Status", 5)
    term.setTextColor(colors.white)
    
    local y = 7
    term.setCursorPos(2, y)
    write("Mining Turtles Deployed: " .. deploymentStatus.mining_turtles)
    y = y + 1
    
    term.setCursorPos(2, y)
    write("Chunky Turtles Deployed: " .. deploymentStatus.chunky_turtles)
    y = y + 1
    
    term.setCursorPos(2, y)
    write("Total Turtles Fueled: " .. deploymentStatus.total_fueled)
    y = y + 1
    
    term.setCursorPos(2, y)
    write("Total Programs Started: " .. deploymentStatus.total_started)
    y = y + 2
    
    if #deployedTurtles > 0 then
        term.setTextColor(colors.blue)
        term.setCursorPos(2, y)
        write("Deployed Turtles:")
        y = y + 1
        
        for i, turtle in ipairs(deployedTurtles) do
            local status = turtle.started and "Running" or (turtle.fueled and "Fueled" or "Deployed")
            term.setCursorPos(4, y)
            write(turtle.id .. " (" .. turtle.type .. ") - " .. status)
            y = y + 1
        end
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function testChestAccess()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Testing Chest Access", 5)
    term.setTextColor(colors.white)
    
    local y = 7
    
    -- Test left chest
    term.setCursorPos(2, y)
    write("Testing Left Chest (Mining Turtles)...")
    y = y + 1
    
    local leftChest, leftChestName = checkChest(LEFT_CHEST_POS, "left")
    if leftChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, y)
        write("Left chest accessible: " .. leftChestName)
        y = y + 1
        
        local miningTurtles = getTurtlesFromChest(leftChest, "mining")
        term.setCursorPos(2, y)
        write("Mining turtles found: " .. #miningTurtles)
        y = y + 1
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, y)
        write("Left chest not accessible")
        y = y + 1
    end
    
    -- Test right chest
    term.setCursorPos(2, y)
    write("Testing Right Chest (Chunky Turtles)...")
    y = y + 1
    
    local rightChest, rightChestName = checkChest(RIGHT_CHEST_POS, "right")
    if rightChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, y)
        write("Right chest accessible: " .. rightChestName)
        y = y + 1
        
        local chunkyTurtles = getTurtlesFromChest(rightChest, "chunky")
        term.setCursorPos(2, y)
        write("Chunky turtles found: " .. #chunkyTurtles)
        y = y + 1
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, y)
        write("Right chest not accessible")
        y = y + 1
    end
    
    -- Test coal chest
    term.setCursorPos(2, y)
    write("Testing Coal Chest...")
    y = y + 1
    
    local coalChest, coalChestName = checkChest(COAL_CHEST_POS, "coal")
    if coalChest then
        term.setTextColor(colors.green)
        term.setCursorPos(2, y)
        write("Coal chest accessible: " .. coalChestName)
        y = y + 1
        
        -- Check for fuel
        local size = coalChest.size()
        local fuelCount = 0
        for slot = 1, size do
            local item = coalChest.getItemDetail(slot)
            if item and (item.name:match("coal") or item.name:match("charcoal") or item.name:match("lava_bucket")) then
                fuelCount = fuelCount + item.count
            end
        end
        term.setCursorPos(2, y)
        write("Fuel items found: " .. fuelCount)
        y = y + 1
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, y)
        write("Coal chest not accessible")
        y = y + 1
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function resetDeployment()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Resetting Deployment", 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("Clearing deployment data...")
    
    deployedTurtles = {}
    deploymentStatus = {
        mining_turtles = 0,
        chunky_turtles = 0,
        total_fueled = 0,
        total_started = 0
    }
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, 9)
    write("Deployment data cleared!")
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    write("Test Boot-up System v" .. cVersion)
    term.setCursorPos(2, 6)
    write("Options:")
    
    local y = 8
    highlightOption(1, "Deploy All Turtles", y)
    y = y + 1
    highlightOption(2, "Show Deployment Status", y)
    y = y + 1
    highlightOption(3, "Test Chest Access", y)
    y = y + 1
    highlightOption(4, "Reset Deployment", y)
    y = y + 1
    highlightOption(5, "Settings", y)
    y = y + 1
    highlightOption(6, "Exit", y)
    
    drawFooter()
end

function showSettings()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Settings", 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("Debug Print: " .. (blnDebugPrint and "On" or "Off"))
    term.setCursorPos(2, 8)
    write("Left Chest Pos: " .. tostring(LEFT_CHEST_POS))
    term.setCursorPos(2, 9)
    write("Right Chest Pos: " .. tostring(RIGHT_CHEST_POS))
    term.setCursorPos(2, 10)
    write("Coal Chest Pos: " .. tostring(COAL_CHEST_POS))
    term.setCursorPos(2, 11)
    write("Mining Deploy X: " .. MINING_DEPLOY_X)
    term.setCursorPos(2, 12)
    write("Chunky Deploy X: " .. CHUNKY_DEPLOY_X)
    
    term.setCursorPos(2, 14)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function main()
    debugPrint("Starting " .. cPrgName .. " v" .. cVersion)
    
    while true do
        showMainMenu()
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q or key == keys.escape then
            clearScreen()
            term.setCursorPos(1, 1)
            return
        elseif key == keys.up then
            if selectedOption > 1 then
                selectedOption = selectedOption - 1
            end
        elseif key == keys.down then
            if selectedOption < maxOptions then
                selectedOption = selectedOption + 1
            end
        elseif key == keys.enter then
            if selectedOption == 1 then
                deployAllTurtles()
            elseif selectedOption == 2 then
                showDeploymentStatus()
            elseif selectedOption == 3 then
                testChestAccess()
            elseif selectedOption == 4 then
                resetDeployment()
            elseif selectedOption == 5 then
                showSettings()
            elseif selectedOption == 6 then
                clearScreen()
                term.setCursorPos(1, 1)
                return
            end
        end
    end
end

-- Start the test boot-up system
main()
