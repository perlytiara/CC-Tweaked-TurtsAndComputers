--{program="chest_manager",version="1.0",date="2024-12-19"}
---------------------------------------
-- Chest Manager                       by AI Assistant
-- 2024-12-19, v1.0   Advanced chest management system
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Advanced chest management system for turtle deployment
-- Manages turtle storage, fuel distribution, and inventory tracking
-- Integrates with the test_bootup and turtle_deployer systems

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v1.0"
local cPrgName = "Chest Manager"
local blnDebugPrint = true

-- Chest management
local managedChests = {}
local chestInventory = {}
local fuelReserves = {}

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
    centerText(" CHEST MANAGER ", 2)
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

function scanChests()
    debugPrint("Scanning for chests...")
    
    managedChests = {}
    chestInventory = {}
    fuelReserves = {}
    
    local peripherals = peripheral.getNames()
    for _, name in ipairs(peripherals) do
        if peripheral.getType(name) == "minecraft:chest" then
            local chest = peripheral.wrap(name)
            if chest then
                local inventory = {}
                local fuelCount = 0
                local turtleCount = 0
                
                local size = chest.size()
                for slot = 1, size do
                    local item = chest.getItemDetail(slot)
                    if item then
                        inventory[slot] = item
                        
                        if item.name:match("coal") or item.name:match("charcoal") or item.name:match("lava_bucket") then
                            fuelCount = fuelCount + item.count
                        elseif item.name:match("turtle") or item.name:match("computer") then
                            turtleCount = turtleCount + item.count
                        end
                    end
                end
                
                managedChests[name] = {
                    chest = chest,
                    name = name,
                    position = name,
                    inventory = inventory,
                    fuelCount = fuelCount,
                    turtleCount = turtleCount
                }
                
                chestInventory[name] = inventory
                fuelReserves[name] = fuelCount
                
                debugPrint("Found chest: " .. name .. " (Turtles: " .. turtleCount .. ", Fuel: " .. fuelCount .. ")")
            end
        end
    end
    
    return managedChests
end

function showChestStatus()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Chest Status", 5)
    term.setTextColor(colors.white)
    
    if not next(managedChests) then
        term.setCursorPos(2, 7)
        write("No chests found. Scanning...")
        scanChests()
    end
    
    local y = 7
    for chestName, chestData in pairs(managedChests) do
        term.setTextColor(colors.blue)
        term.setCursorPos(2, y)
        write("Chest: " .. chestName)
        y = y + 1
        
        term.setTextColor(colors.white)
        term.setCursorPos(4, y)
        write("Turtles: " .. chestData.turtleCount)
        term.setCursorPos(20, y)
        write("Fuel: " .. chestData.fuelCount)
        y = y + 1
        
        y = y + 1 -- Extra space
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showDetailedInventory()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Detailed Inventory", 5)
    term.setTextColor(colors.white)
    
    if not next(managedChests) then
        scanChests()
    end
    
    local y = 7
    for chestName, chestData in pairs(managedChests) do
        term.setTextColor(colors.blue)
        term.setCursorPos(2, y)
        write("=== " .. chestName .. " ===")
        y = y + 1
        
        local hasItems = false
        for slot, item in pairs(chestData.inventory) do
            if item then
                term.setTextColor(colors.white)
                term.setCursorPos(4, y)
                write("Slot " .. slot .. ": " .. item.name .. " x" .. item.count)
                y = y + 1
                hasItems = true
            end
        end
        
        if not hasItems then
            term.setTextColor(colors.gray)
            term.setCursorPos(4, y)
            write("Empty")
            y = y + 1
        end
        
        y = y + 1 -- Extra space
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function distributeFuel()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Fuel Distribution", 5)
    term.setTextColor(colors.white)
    
    if not next(managedChests) then
        scanChests()
    end
    
    local totalFuel = 0
    local fuelChests = {}
    
    -- Find all fuel sources
    for chestName, chestData in pairs(managedChests) do
        if chestData.fuelCount > 0 then
            table.insert(fuelChests, {name = chestName, fuel = chestData.fuelCount})
            totalFuel = totalFuel + chestData.fuelCount
        end
    end
    
    term.setCursorPos(2, 7)
    write("Total fuel available: " .. totalFuel)
    term.setCursorPos(2, 8)
    write("Fuel sources: " .. #fuelChests)
    
    if #fuelChests == 0 then
        term.setTextColor(colors.red)
        term.setCursorPos(2, 10)
        write("No fuel sources found!")
    else
        term.setTextColor(colors.green)
        term.setCursorPos(2, 10)
        write("Fuel distribution ready")
        
        local y = 12
        for i, fuelSource in ipairs(fuelChests) do
            term.setCursorPos(2, y)
            write(fuelSource.name .. ": " .. fuelSource.fuel .. " fuel")
            y = y + 1
        end
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showTurtleInventory()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Turtle Inventory", 5)
    term.setTextColor(colors.white)
    
    if not next(managedChests) then
        scanChests()
    end
    
    local totalTurtles = 0
    local y = 7
    
    for chestName, chestData in pairs(managedChests) do
        if chestData.turtleCount > 0 then
            term.setTextColor(colors.blue)
            term.setCursorPos(2, y)
            write("Chest: " .. chestName)
            y = y + 1
            
            term.setTextColor(colors.white)
            term.setCursorPos(4, y)
            write("Turtles: " .. chestData.turtleCount)
            y = y + 1
            
            totalTurtles = totalTurtles + chestData.turtleCount
            y = y + 1
        end
    end
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, y)
    write("Total turtles available: " .. totalTurtles)
    
    if totalTurtles == 0 then
        term.setTextColor(colors.red)
        term.setCursorPos(2, y + 2)
        write("No turtles found in any chest!")
    end
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    write("Chest Manager v" .. cVersion)
    term.setCursorPos(2, 6)
    write("Options:")
    
    local y = 8
    highlightOption(1, "Scan Chests", y)
    y = y + 1
    highlightOption(2, "Chest Status", y)
    y = y + 1
    highlightOption(3, "Detailed Inventory", y)
    y = y + 1
    highlightOption(4, "Distribute Fuel", y)
    y = y + 1
    highlightOption(5, "Turtle Inventory", y)
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
    write("Managed Chests: " .. (next(managedChests) and "Yes" or "No"))
    
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function main()
    debugPrint("Starting " .. cPrgName .. " v" .. cVersion)
    
    -- Initial scan
    scanChests()
    
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
                scanChests()
                clearScreen()
                drawHeader()
                term.setTextColor(colors.green)
                centerText("Chests Scanned!", 5)
                term.setTextColor(colors.white)
                term.setCursorPos(2, 7)
                write("Found " .. (next(managedChests) and "chests" or "0 chests"))
                term.setCursorPos(2, h - 1)
                write("Press any key to continue...")
                os.pullEvent("key")
            elseif selectedOption == 2 then
                showChestStatus()
            elseif selectedOption == 3 then
                showDetailedInventory()
            elseif selectedOption == 4 then
                distributeFuel()
            elseif selectedOption == 5 then
                showTurtleInventory()
            elseif selectedOption == 6 then
                clearScreen()
                term.setCursorPos(1, 1)
                return
            end
        end
    end
end

-- Start the chest manager
main()
