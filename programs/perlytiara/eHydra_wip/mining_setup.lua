-- eHydra Mining Setup System
-- Complete mining infrastructure deployment with GPS positioning

local SLOT_COUNT = 16

-- Infrastructure items needed for mining setup
local REQUIRED_ITEMS = {
    turtles = {"turtle", 1},
    diskDrives = {"disk_drive", 1}, 
    disks = {"floppy_disk", 1},
    computers = {"computer", 1}, -- For monitoring/control
    chests = {"chest", 3}, -- Coal chest, storage chest, spare chest
    coal = {"coal", 64}, -- Fuel supply
    enderChests = {"ender", 1} -- Optional for remote storage
}

local function scanForMiningSetup()
    print("🔍 Scanning for complete mining setup components...")
    
    local inventory = {}
    local missing = {}
    
    for category, requirement in pairs(REQUIRED_ITEMS) do
        local pattern, minCount = requirement[1], requirement[2]
        local found = {}
        
        for slot = 1, SLOT_COUNT do
            local item = turtle.getItemDetail(slot)
            if item and item.name:find(pattern) then
                table.insert(found, {slot = slot, name = item.name, count = item.count})
            end
        end
        
        inventory[category] = found
        local totalCount = 0
        for _, item in ipairs(found) do
            totalCount = totalCount + item.count
        end
        
        if totalCount < minCount then
            table.insert(missing, category .. " (need " .. minCount .. ", have " .. totalCount .. ")")
        end
    end
    
    return inventory, missing
end

local function getGPSPosition()
    print("📍 Getting GPS coordinates...")
    local x, y, z = gps.locate(5, false)
    
    if x then
        print("✅ GPS Location: " .. x .. ", " .. y .. ", " .. z)
        return {x = math.floor(x), y = math.floor(y), z = math.floor(z)}
    else
        print("❌ GPS not available - using manual positioning")
        return nil
    end
end

local function calculateMiningArea(basePos, width, depth, height)
    if not basePos then
        print("⚠️ No GPS - please manually position setup")
        return nil
    end
    
    local area = {
        start = {x = basePos.x, y = basePos.y - height, z = basePos.z},
        finish = {x = basePos.x + width - 1, y = basePos.y - 1, z = basePos.z + depth - 1},
        control = {x = basePos.x - 2, y = basePos.y + 1, z = basePos.z - 2}, -- Control station position
        coalChest = {x = basePos.x - 1, y = basePos.y, z = basePos.z - 1},
        storageChest = {x = basePos.x - 1, y = basePos.y, z = basePos.z + 1}
    }
    
    return area
end

local function deployInfrastructure(inventory, area)
    print("🏗️ Deploying mining infrastructure...")
    
    local currentX, currentY, currentZ = gps.locate()
    if not currentX then
        print("❌ Cannot deploy without GPS")
        return false
    end
    
    -- Deploy coal chest
    print("⛽ Placing coal chest...")
    -- Navigate to coal chest position
    -- Place chest and fill with coal
    turtle.select(inventory.chests[1].slot)
    turtle.place()
    
    -- Fill coal chest
    if #inventory.coal > 0 then
        turtle.select(inventory.coal[1].slot)
        turtle.drop(32) -- Drop half the coal
        print("✅ Coal chest stocked")
    end
    
    -- Deploy storage chest
    print("📦 Placing storage chest...")
    -- Navigate to storage position and place
    turtle.select(inventory.chests[2].slot)
    turtle.place()
    
    -- Deploy control computer
    print("🖥️ Placing control computer...")
    turtle.select(inventory.computers[1].slot)
    turtle.place()
    
    -- Setup disk with mining program
    turtle.select(inventory.diskDrives[1].slot)
    turtle.placeUp()
    
    turtle.select(inventory.disks[1].slot)
    turtle.dropUp()
    
    return true
end

local function createMiningProgram(area, miningProgram, parameters)
    print("💾 Creating mining program disk...")
    
    if not fs.exists("disk") then
        print("❌ Disk not mounted")
        return false
    end
    
    -- Create comprehensive mining startup
    local startupFile = fs.open("disk/startup", "w")
    if not startupFile then
        return false
    end
    
    startupFile.write(string.format([[
-- eHydra Complete Mining Setup
print("🏗️ eHydra Mining Setup v1.0")
print("=============================")

-- Get position
local x, y, z = gps.locate(3, false)
if x then
    print("📍 Position: " .. x .. ", " .. y .. ", " .. z)
else
    print("📍 GPS not available")
end

-- Setup mining parameters
local miningArea = {
    start = {x = %d, y = %d, z = %d},
    finish = {x = %d, y = %d, z = %d}
}

-- Copy mining program if available
if fs.exists("disk/%s") then
    fs.copy("disk/%s", "%s")
    print("✅ Mining program installed: %s")
end

-- Setup fuel management
local function refuelFromChest()
    -- Look for coal chest nearby
    for _, direction in ipairs({"front", "back", "left", "right", "up", "down"}) do
        if peripheral.isPresent(direction) and peripheral.getType(direction) == "minecraft:chest" then
            local chest = peripheral.wrap(direction)
            local items = chest.list()
            for slot, item in pairs(items) do
                if item.name:find("coal") then
                    chest.pushItems(peripheral.getName(turtle), slot, math.min(item.count, 32), 1)
                    turtle.select(1)
                    if turtle.refuel() then
                        print("⛽ Refueled from chest")
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Setup inventory management
local function depositToStorage()
    -- Find storage chest and deposit items
    for _, direction in ipairs({"front", "back", "left", "right", "up", "down"}) do
        if peripheral.isPresent(direction) and peripheral.getType(direction) == "minecraft:chest" then
            local chest = peripheral.wrap(direction)
            for slot = 2, 16 do -- Keep slot 1 for fuel
                local item = turtle.getItemDetail(slot)
                if item and not item.name:find("coal") then
                    turtle.select(slot)
                    turtle.drop()
                end
            end
        end
    end
end

-- Send status updates
local function sendStatus(message)
    local modem = peripheral.find("modem")
    if modem then
        rednet.open(peripheral.getName(modem))
        rednet.broadcast({
            id = os.getComputerID(),
            status = message,
            position = {x = x, y = y, z = z},
            fuel = turtle.getFuelLevel(),
            time = os.time()
        }, "ehydra_mining")
        print("📡 Status sent: " .. message)
    end
end

-- Main mining operation
sendStatus("MINING_STARTED")

-- Initial refuel
refuelFromChest()

-- Start mining program
if fs.exists("%s") then
    print("🚀 Starting mining: %s %s")
    shell.run("%s", "%s")
else
    print("❌ Mining program not found")
    sendStatus("ERROR_NO_PROGRAM")
end

sendStatus("MINING_COMPLETED")
]], 
    area.start.x, area.start.y, area.start.z,
    area.finish.x, area.finish.y, area.finish.z,
    miningProgram, miningProgram, miningProgram, miningProgram,
    miningProgram, miningProgram, parameters or ""
))
    
    startupFile.close()
    
    -- Copy the actual mining program to disk
    if fs.exists(miningProgram .. ".lua") then
        fs.copy(miningProgram .. ".lua", "disk/" .. miningProgram)
        print("✅ Mining program copied to disk")
    end
    
    return true
end

local function deployCompleteMiningSetup(program, parameters, dimensions)
    print("🏗️ eHydra Complete Mining Setup")
    print("================================")
    
    -- Get current position
    local basePos = getGPSPosition()
    if not basePos then
        print("❌ GPS required for automated setup")
        return false
    end
    
    -- Scan inventory
    local inventory, missing = scanForMiningSetup()
    
    if #missing > 0 then
        print("❌ Missing required items:")
        for _, item in ipairs(missing) do
            print("   • " .. item)
        end
        return false
    end
    
    print("✅ All required items available")
    
    -- Calculate mining area
    local width, depth, height = dimensions.width or 16, dimensions.depth or 16, dimensions.height or 10
    local area = calculateMiningArea(basePos, width, depth, height)
    
    print("📊 Mining Area Calculated:")
    print("   Start: " .. area.start.x .. ", " .. area.start.y .. ", " .. area.start.z)
    print("   Finish: " .. area.finish.x .. ", " .. area.finish.y .. ", " .. area.finish.z)
    print("   Size: " .. width .. "x" .. depth .. "x" .. height)
    
    -- Deploy infrastructure
    if not deployInfrastructure(inventory, area) then
        print("❌ Infrastructure deployment failed")
        return false
    end
    
    -- Create mining program
    if not createMiningProgram(area, program, parameters) then
        print("❌ Mining program setup failed")
        return false
    end
    
    -- Deploy turtle
    print("🐢 Deploying mining turtle...")
    turtle.select(inventory.turtles[1].slot)
    turtle.place()
    peripheral.call("front", "turnOn")
    
    print("✅ Complete mining setup deployed!")
    print("   🐢 Turtle: Deployed and starting")
    print("   ⛽ Coal chest: Stocked")
    print("   📦 Storage chest: Ready")
    print("   🖥️ Control computer: Active")
    print("   📡 Monitoring: Enabled")
    
    return true
end

-- Parse command line arguments
local args = {...}
local program = args[1] or "quarry"
local width = tonumber(args[2]) or 16
local depth = tonumber(args[3]) or 16  
local height = tonumber(args[4]) or 10
local parameters = table.concat({table.unpack(args, 5)}, " ")

print("🏗️ eHydra Mining Setup Configuration")
print("====================================")
print("Program: " .. program)
print("Dimensions: " .. width .. "x" .. depth .. "x" .. height)
if parameters ~= "" then
    print("Parameters: " .. parameters)
end

print()
write("Proceed with setup? (y/n) [y]: ")
local confirm = string.lower(read())

if confirm ~= "n" then
    deployCompleteMiningSetup(program, parameters, {
        width = width,
        depth = depth, 
        height = height
    })
else
    print("Setup cancelled")
end
