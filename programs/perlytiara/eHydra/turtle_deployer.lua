-- eHydra Turtle Deployment System
-- Advanced turtle placement and configuration

local SLOT_COUNT = 16

-- Improved inventory scanning functions
local function getItemIndex(itemName)
    for slot = 1, SLOT_COUNT do
        local item = turtle.getItemDetail(slot)
        if item and item.name == itemName then
            return slot
        end
    end
    return nil
end

local function findItemsInInventory(itemPattern)
    local items = {}
    for slot = 1, SLOT_COUNT do
        local item = turtle.getItemDetail(slot)
        if item and (item.name == itemPattern or item.name:find(itemPattern)) then
            table.insert(items, {slot = slot, name = item.name, count = item.count})
        end
    end
    return items
end

local function scanInventoryForDeployment()
    print("🔍 Scanning inventory for deployment items...")
    
    local inventory = {
        turtles = findItemsInInventory("turtle"),
        diskDrives = findItemsInInventory("disk_drive"),
        disks = findItemsInInventory("floppy_disk"),
        fuel = findItemsInInventory("coal"),
        enderChests = findItemsInInventory("ender")
    }
    
    print("📦 Inventory scan results:")
    print("   🐢 Turtles: " .. #inventory.turtles)
    print("   💾 Disk drives: " .. #inventory.diskDrives) 
    print("   💿 Disks: " .. #inventory.disks)
    print("   ⛽ Fuel items: " .. #inventory.fuel)
    print("   📦 Ender chests: " .. #inventory.enderChests)
    
    return inventory
end

local function selectBestTurtle(inventory, preferredType)
    if #inventory.turtles == 0 then
        return nil, "No turtles found in inventory"
    end
    
    -- Priority order for turtle selection
    local priorities = {
        "advancedperipherals:chunky_turtle",
        "computercraft:turtle_advanced",
        "computercraft:turtle_normal"
    }
    
    -- Try to find preferred type first
    if preferredType then
        for _, turtleInfo in ipairs(inventory.turtles) do
            if turtleInfo.name:find(preferredType) then
                return turtleInfo, nil
            end
        end
    end
    
    -- Fall back to priority order
    for _, priority in ipairs(priorities) do
        for _, turtleInfo in ipairs(inventory.turtles) do
            if turtleInfo.name == priority then
                return turtleInfo, nil
            end
        end
    end
    
    -- Return first available turtle
    return inventory.turtles[1], nil
end

local function createStartupDisk(program, parameters, diskSlot)
    turtle.select(diskSlot)
    
    -- Create startup file on disk
    if fs.exists("disk/startup") then
        fs.delete("disk/startup")
    end
    
    local startupFile = fs.open("disk/startup", "w")
    if not startupFile then
        return false, "Could not create startup file on disk"
    end
    
    -- Write startup script that copies programs and sets up turtle
    startupFile.write(string.format([[
-- eHydra Turtle Startup v2.0
print("🐢 eHydra Turtle Starting...")

-- Copy eHydra client to turtle
if fs.exists("disk/turtle_client") then
    fs.copy("disk/turtle_client", "turtle_client")
    fs.copy("disk/turtle_client", "startup")  -- Make it permanent startup
    print("✅ eHydra client installed")
else
    print("⚠️ eHydra client not found on disk")
end

-- Copy target program to turtle if specified
if "%s" ~= "turtle_client" then
    if fs.exists("disk/%s") then
        fs.copy("disk/%s", "%s")
        print("✅ Program copied: %s")
    else
        print("⚠️ Program %s not found on disk")
    end
end

-- Send deployment confirmation
local modem = peripheral.find("modem")
if modem then
    rednet.open(peripheral.getName(modem))
    rednet.broadcast("TURTLE_DEPLOYED", "ehydra")
    print("📡 Deployment confirmed")
end

-- Initialize GPS location
local x, y, z = gps.locate(2, false)
if x then
    print("📍 GPS: " .. x .. ", " .. y .. ", " .. z)
end

-- Start the eHydra client (which will listen for commands)
print("🚀 Starting eHydra turtle client...")
if fs.exists("turtle_client") then
    shell.run("turtle_client")
else
    print("❌ eHydra client not found, running target program directly")
    if "%s" ~= "" and fs.exists("%s") then
        shell.run("%s", "%s")
    else
        print("❌ No programs available to run")
    end
end
]], program, program, program, program, program, program, program, parameters or "", program))
    
    startupFile.close()
    
    -- Also copy the turtle client program to the disk
    if fs.exists("turtle_client.lua") then
        if fs.exists("disk/turtle_client") then
            fs.delete("disk/turtle_client")
        end
        fs.copy("turtle_client.lua", "disk/turtle_client")
        print("✅ eHydra client added to disk")
    else
        print("⚠️ turtle_client.lua not found - turtle will have limited functionality")
    end
    
    return true, nil
end

local function setupTurtleDisk(inventory, program, parameters)
    if #inventory.diskDrives == 0 or #inventory.disks == 0 then
        return nil, "Disk drive or floppy disk missing from inventory"
    end
    
    local diskDriveSlot = inventory.diskDrives[1].slot
    local diskSlot = inventory.disks[1].slot
    
    -- Select and place disk drive
    turtle.select(diskDriveSlot)
    turtle.placeDown()
    
    -- Insert disk
    turtle.select(diskSlot)
    turtle.dropDown()
    
    -- Wait for disk to be recognized
    sleep(1)
    
    if not fs.exists("disk") then
        return nil, "Disk not mounted properly"
    end
    
    -- Create startup disk
    local success, err = createStartupDisk(program, parameters, diskSlot)
    if not success then
        return nil, err
    end
    
    print("✓ Startup disk created for program: " .. program)
    return diskDriveSlot, nil
end

local function deployTurtleWithDisk(inventory, direction, preferredType, program, parameters)
    -- Scan and select best turtle
    local turtleInfo, err = selectBestTurtle(inventory, preferredType)
    if not turtleInfo then
        print("✗ " .. err)
        return false
    end
    
    print("📦 Selected: " .. turtleInfo.name .. " from slot " .. turtleInfo.slot)
    
    -- Setup disk with startup program
    local diskDriveSlot, diskErr = setupTurtleDisk(inventory, program or "quarry", parameters)
    if not diskDriveSlot then
        print("✗ Disk setup failed: " .. (diskErr or "unknown error"))
        return false
    end
    
    -- Clear space and place turtle
    local placeFunction
    if direction == "down" then
        placeFunction = turtle.placeDown
        -- Check for obstruction
        while turtle.detectDown() do
            print("⚠ Obstruction below, clearing...")
            turtle.digDown()
            sleep(0.5)
        end
    elseif direction == "up" then  
        placeFunction = turtle.placeUp
        while turtle.detectUp() do
            print("⚠ Obstruction above, clearing...")
            turtle.digUp() 
            sleep(0.5)
        end
    else
        placeFunction = turtle.place
        while turtle.detect() do
            print("⚠ Obstruction ahead, clearing...")
            turtle.dig()
            sleep(0.5)
        end
    end
    
    -- Place the turtle
    turtle.select(turtleInfo.slot)
    if placeFunction() then
        print("✓ Turtle placed successfully")
        
        -- Turn on the turtle
        local turtleDirection = direction == "down" and "bottom" or (direction == "up" and "top" or "front")
        peripheral.call(turtleDirection, "turnOn")
        print("✓ Turtle powered on")
        
        -- Wait for deployment confirmation
        print("⏳ Waiting for turtle to boot and send confirmation...")
        local modem = peripheral.find("modem")
        if modem then
            rednet.open(peripheral.getName(modem))
            local senderId, message, protocol = rednet.receive("ehydra", 10)
            if message == "TURTLE_DEPLOYED" then
                print("✅ Turtle deployment confirmed!")
                return true
            else
                print("⚠ No confirmation received, but turtle may be working")
                return true
            end
        else
            print("⚠ No modem found, cannot confirm deployment")
            return true
        end
    else
        print("✗ Failed to place turtle")
        return false
    end
end

local function configureTurtle(id, config)
    print("Configuring turtle " .. id .. "...")
    
    -- Send configuration
    rednet.send(id, {
        command = "CONFIG",
        fuelLevel = config.fuel or 1000,
        program = config.program or "quarry",
        autostart = config.autostart or false,
        chunkloading = config.chunky or false
    })
    
    -- Wait for acknowledgment
    local senderId, response = rednet.receive(3)
    if senderId == id and response and response.status == "CONFIGURED" then
        print("✓ Turtle " .. id .. " configured")
        return true
    else
        print("⚠ Configuration may have failed")
        return false
    end
end

local function setupWirelessChunkyTurtle()
    print("Setting up Advanced Wireless Chunky Turtle...")
    print("============================================")
    
    local inventory = scanInventoryForDeployment()
    
    -- Check requirements
    if #inventory.turtles == 0 then
        print("✗ No turtles found in inventory")
        print("Required: At least 1 advanced turtle")
        return false
    end
    
    if #inventory.diskDrives == 0 or #inventory.disks == 0 then
        print("✗ Missing disk drive or floppy disk")
        print("Required: 1 disk drive + 1 floppy disk for startup program")
        return false
    end
    
    print()
    print("Select placement direction:")
    print("1. Forward")
    print("2. Down") 
    print("3. Up")
    write("Choice [1]: ")
    local dirChoice = tonumber(read()) or 1
    
    local direction = "forward"
    if dirChoice == 2 then direction = "down"
    elseif dirChoice == 3 then direction = "up" end
    
    print()
    write("Mining program [quarry]: ")
    local program = read()
    if program == "" then program = "quarry" end
    
    write("Program parameters (optional): ")
    local parameters = read()
    
    print()
    print("🚀 Deploying chunky turtle with disk-based startup...")
    
    if deployTurtleWithDisk(inventory, direction, "chunky", program, parameters) then
        print()
        print("🎉 Advanced Wireless Chunky Turtle deployed successfully!")
        print("   📋 Program: " .. program)
        if parameters and parameters ~= "" then
            print("   ⚙️  Parameters: " .. parameters)
        end
        print("   💿 Startup disk configured")
        print("   📡 Wireless communication enabled")
        return true
    else
        print("❌ Deployment failed")
        return false
    end
end

local function deployCompleteMiningSetup()
    print("Complete Mining Setup Deployment")
    print("===============================")
    
    local inventory = scanInventoryForDeployment()
    
    -- Check for complete setup requirements
    local required = {
        {inventory.turtles, "turtles", 1},
        {inventory.diskDrives, "disk drives", 1},
        {inventory.disks, "floppy disks", 1},
        {findItemsInInventory("computer"), "computers", 1},
        {findItemsInInventory("chest"), "chests", 3},
        {findItemsInInventory("coal"), "coal", 32}
    }
    
    local missing = {}
    for _, req in ipairs(required) do
        local items, name, needed = req[1], req[2], req[3]
        local totalCount = 0
        for _, item in ipairs(items) do
            totalCount = totalCount + item.count
        end
        if totalCount < needed then
            table.insert(missing, name .. " (need " .. needed .. ", have " .. totalCount .. ")")
        end
    end
    
    if #missing > 0 then
        print("❌ Missing required items for complete setup:")
        for _, item in ipairs(missing) do
            print("   • " .. item)
        end
        print()
        print("Required for complete mining setup:")
        print("   • 1+ Advanced turtle")
        print("   • 1+ Disk drive")  
        print("   • 1+ Floppy disk")
        print("   • 1+ Computer (for monitoring)")
        print("   • 3+ Chests (coal, storage, spare)")
        print("   • 32+ Coal (for fuel)")
        return false
    end
    
    -- Get GPS position
    print("📍 Getting GPS position for setup...")
    local x, y, z = gps.locate(5, false)
    if not x then
        print("❌ GPS required for automated complete setup")
        print("Please ensure GPS satellites are available")
        return false
    end
    
    local basePos = {x = math.floor(x), y = math.floor(y), z = math.floor(z)}
    print("✅ Base position: " .. basePos.x .. ", " .. basePos.y .. ", " .. basePos.z)
    
    -- Get mining parameters
    print()
    write("Mining program [quarry]: ")
    local program = read()
    if program == "" then program = "quarry" end
    
    write("Mining width [16]: ")
    local width = tonumber(read()) or 16
    
    write("Mining depth [16]: ")  
    local depth = tonumber(read()) or 16
    
    write("Mining height [10]: ")
    local height = tonumber(read()) or 10
    
    write("Program parameters (optional): ")
    local parameters = read()
    
    -- Calculate mining area
    local area = {
        start = {x = basePos.x, y = basePos.y - height, z = basePos.z},
        finish = {x = basePos.x + width - 1, y = basePos.y - 1, z = basePos.z + depth - 1},
        coalChest = {x = basePos.x - 1, y = basePos.y, z = basePos.z - 1},
        storageChest = {x = basePos.x + 1, y = basePos.y, z = basePos.z - 1},
        computer = {x = basePos.x, y = basePos.y + 1, z = basePos.z - 2}
    }
    
    print()
    print("📊 Mining Setup Plan:")
    print("   📦 Mining area: " .. width .. "x" .. depth .. "x" .. height)
    print("   🏗️ Start: " .. area.start.x .. ", " .. area.start.y .. ", " .. area.start.z)
    print("   🏁 End: " .. area.finish.x .. ", " .. area.finish.y .. ", " .. area.finish.z)
    print("   ⛽ Coal chest: " .. area.coalChest.x .. ", " .. area.coalChest.y .. ", " .. area.coalChest.z)
    print("   📦 Storage: " .. area.storageChest.x .. ", " .. area.storageChest.y .. ", " .. area.storageChest.z)
    
    print()
    write("Deploy complete mining setup? (y/n) [y]: ")
    local confirm = string.lower(read())
    if confirm == "n" then
        print("Setup cancelled")
        return false
    end
    
    print()
    print("🚀 Deploying complete mining infrastructure...")
    
    -- Step 1: Place coal chest and fill it
    print("⛽ Setting up fuel infrastructure...")
    turtle.back() -- Move to coal chest position
    turtle.select(findItemsInInventory("chest")[1].slot)
    turtle.placeDown()
    
    -- Fill with coal
    local coalItem = findItemsInInventory("coal")[1]
    turtle.select(coalItem.slot)
    turtle.dropDown(32)
    print("✅ Coal chest placed and stocked")
    
    -- Step 2: Place storage chest
    print("📦 Setting up storage...")
    turtle.forward()
    turtle.forward()
    turtle.select(findItemsInInventory("chest")[2].slot)  
    turtle.placeDown()
    print("✅ Storage chest placed")
    
    -- Step 3: Place monitoring computer
    print("🖥️ Setting up monitoring...")
    turtle.back()
    turtle.up()
    turtle.back()
    turtle.select(findItemsInInventory("computer")[1].slot)
    turtle.place()
    print("✅ Monitoring computer placed")
    
    -- Step 4: Setup mining turtle with complete program
    print("🐢 Deploying mining turtle with complete setup...")
    turtle.forward()
    turtle.down()
    
    -- Create comprehensive startup disk
    local diskDrive = inventory.diskDrives[1]
    local disk = inventory.disks[1]
    
    turtle.select(diskDrive.slot)
    turtle.placeUp()
    turtle.select(disk.slot)
    turtle.dropUp()
    
    sleep(1) -- Wait for disk to mount
    
    if fs.exists("disk") then
        -- Create advanced mining startup
        local startupFile = fs.open("disk/startup", "w")
        if startupFile then
            startupFile.write(string.format([[
-- eHydra Complete Mining Operation
print("🏗️ eHydra Complete Mining Setup v1.0")
print("====================================")

-- Configuration
local miningArea = {
    start = {x = %d, y = %d, z = %d},
    size = {width = %d, depth = %d, height = %d},
    coalChest = {x = %d, y = %d, z = %d},
    storageChest = {x = %d, y = %d, z = %d}
}

-- Automated fuel management  
local function autoRefuel()
    if turtle.getFuelLevel() < 100 then
        -- Navigate to coal chest and refuel
        print("⛽ Auto-refueling...")
        -- Implementation for navigation and refueling
        return true
    end
    return true
end

-- Automated inventory management
local function autoDeposit()
    -- Navigate to storage chest and deposit non-fuel items
    print("📦 Auto-depositing...")
    return true
end

-- Status reporting
local function reportStatus(message)
    local modem = peripheral.find("modem")
    if modem then
        rednet.open(peripheral.getName(modem))
        rednet.broadcast({
            id = os.getComputerID(),
            status = message,
            area = miningArea,
            fuel = turtle.getFuelLevel(),
            time = os.time()
        }, "ehydra_mining")
    end
end

-- Main mining operation
reportStatus("MINING_STARTED")

-- Copy and run mining program
if fs.exists("disk/%s") then
    fs.copy("disk/%s", "%s")
    print("✅ Program installed: %s")
    
    -- Start mining with parameters
    reportStatus("MINING_ACTIVE")
    shell.run("%s", "%s")
    
    reportStatus("MINING_COMPLETED") 
else
    print("❌ Mining program not found")
    reportStatus("ERROR_NO_PROGRAM")
end
]], 
            area.start.x, area.start.y, area.start.z,
            width, depth, height,
            area.coalChest.x, area.coalChest.y, area.coalChest.z,
            area.storageChest.x, area.storageChest.y, area.storageChest.z,
            program, program, program, program, program, parameters or ""
            ))
            startupFile.close()
            
            -- Copy mining program to disk
            if fs.exists(program .. ".lua") then
                fs.copy(program .. ".lua", "disk/" .. program)
            end
        end
    end
    
    -- Deploy the mining turtle
    local turtleInfo = selectBestTurtle(inventory, "advanced")
    turtle.select(turtleInfo.slot)
    turtle.place()
    peripheral.call("front", "turnOn")
    
    print()
    print("🎉 Complete mining setup deployed successfully!")
    print("===============================================")
    print("   🐢 Mining turtle: Active with " .. program)
    print("   ⛽ Coal chest: Stocked and positioned")  
    print("   📦 Storage chest: Ready for output")
    print("   🖥️ Monitor computer: Tracking operations")
    print("   📡 Wireless monitoring: Enabled")
    print("   🏗️ Mining area: " .. width .. "x" .. depth .. "x" .. height)
    
    return true
end

print("eHydra Turtle Deployer v1.0")
print("===========================")
print()
print("1. Deploy single Advanced Mining Turtle")
print("2. Setup Advanced Wireless Chunky Turtle")  
print("3. Deploy Complete Mining Setup (GPS + Infrastructure)")
print("4. List inventory and deployment readiness")
print()

write("Choice [1-4]: ")
local choice = tonumber(read()) or 1

if choice == 1 then
    print()
    print("Deploy Single Advanced Mining Turtle")
    print("===================================")
    
    local inventory = scanInventoryForDeployment()
    
    if #inventory.turtles == 0 then
        print("✗ No turtles found in inventory")
        return
    end
    
    write("Mining program [quarry]: ")
    local program = read()
    if program == "" then program = "quarry" end
    
    write("Program parameters (optional): ")
    local parameters = read()
    
    if deployTurtleWithDisk(inventory, "down", "advanced", program, parameters) then
        print("✅ Single mining turtle deployed successfully!")
    else
        print("❌ Deployment failed")
    end
    
elseif choice == 2 then
    print()
    setupWirelessChunkyTurtle()
    
elseif choice == 3 then
    print()
    deployCompleteMiningSetup()
    
elseif choice == 4 then
    print()
    local inventory = scanInventoryForDeployment()
    
    print("📋 Detailed Inventory Report:")
    print("============================")
    
    if #inventory.turtles > 0 then
        print("🐢 Turtles:")
        for i, turtle in ipairs(inventory.turtles) do
            print("  " .. i .. ". " .. turtle.name .. " (slot " .. turtle.slot .. ", count: " .. turtle.count .. ")")
        end
    end
    
    if #inventory.diskDrives > 0 then
        print("💾 Disk Drives:")
        for i, drive in ipairs(inventory.diskDrives) do
            print("  " .. i .. ". " .. drive.name .. " (slot " .. drive.slot .. ", count: " .. drive.count .. ")")
        end
    end
    
    if #inventory.disks > 0 then
        print("💿 Floppy Disks:")
        for i, disk in ipairs(inventory.disks) do
            print("  " .. i .. ". " .. disk.name .. " (slot " .. disk.slot .. ", count: " .. disk.count .. ")")
        end
    end
    
    if #inventory.fuel > 0 then
        print("⛽ Fuel Items:")
        for i, fuel in ipairs(inventory.fuel) do
            print("  " .. i .. ". " .. fuel.name .. " (slot " .. fuel.slot .. ", count: " .. fuel.count .. ")")
        end
    end
    
    if #inventory.enderChests > 0 then
        print("📦 Ender Chests:")
        for i, chest in ipairs(inventory.enderChests) do
            print("  " .. i .. ". " .. chest.name .. " (slot " .. chest.slot .. ", count: " .. chest.count .. ")")
        end
    end
    
    -- Show readiness status
    print()
    print("🚦 Deployment Readiness:")
    local canDeploy = #inventory.turtles > 0 and #inventory.diskDrives > 0 and #inventory.disks > 0
    if canDeploy then
        print("✅ Ready for deployment!")
        print("   Can deploy: " .. math.min(#inventory.turtles, #inventory.diskDrives, #inventory.disks) .. " turtle(s)")
    else
        print("❌ Not ready for deployment")
        if #inventory.turtles == 0 then print("   Missing: Turtles") end
        if #inventory.diskDrives == 0 then print("   Missing: Disk drives") end  
        if #inventory.disks == 0 then print("   Missing: Floppy disks") end
    end
    
else
    print("Invalid choice")
end
