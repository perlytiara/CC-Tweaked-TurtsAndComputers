-- eHydra Turtle Deployment System
-- Advanced turtle placement and configuration

local function findTurtleInInventory(turtleType)
    local turtleItems = {
        "computercraft:turtle_normal",
        "computercraft:turtle_advanced", 
        "advancedperipherals:chunky_turtle"
    }
    
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            for _, turtleName in ipairs(turtleItems) do
                if item.name == turtleName or item.name:find("turtle") then
                    return slot, item.name
                end
            end
        end
    end
    return nil, nil
end

local function deployTurtleAtPosition(direction, turtleType)
    local slot, itemName = findTurtleInInventory(turtleType)
    if not slot then
        print("✗ No turtle found in inventory")
        return false
    end
    
    turtle.select(slot)
    print("Found " .. itemName .. " in slot " .. slot)
    
    local placeFunction
    if direction == "down" then
        placeFunction = turtle.placeDown
    elseif direction == "up" then  
        placeFunction = turtle.placeUp
    else
        placeFunction = turtle.place
    end
    
    if placeFunction() then
        print("✓ Turtle placed successfully")
        return true
    else
        print("✗ Failed to place turtle - check space/blocks")
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
    
    -- Check for chunky turtle specifically
    local slot, itemName = findTurtleInInventory("chunky")
    if not slot then
        print("Looking for any advanced turtle...")
        slot, itemName = findTurtleInInventory("advanced")
    end
    
    if not slot then
        print("✗ No suitable turtle found")
        return false
    end
    
    print("Select placement direction:")
    print("1. Forward")
    print("2. Down") 
    print("3. Up")
    write("Choice [1]: ")
    local dirChoice = tonumber(read()) or 1
    
    local direction = "forward"
    if dirChoice == 2 then direction = "down"
    elseif dirChoice == 3 then direction = "up" end
    
    if deployTurtleAtPosition(direction, "advanced") then
        print()
        print("Turtle deployed! Waiting for boot...")
        sleep(3)
        
        write("Enter turtle ID (if known): ")
        local id = tonumber(read())
        
        if id then
            configureTurtle(id, {
                fuel = 2000,
                program = "quarry",
                autostart = true,
                chunky = true
            })
        else
            print("Manual configuration required")
            print("Use 'rednet.send(<id>, {command=\"CONFIG\",...})' to configure")
        end
        
        return true
    end
    
    return false
end

local function deployMiningFleet()
    print("Mining Fleet Deployment")
    print("======================")
    
    write("Number of turtles [3]: ")
    local count = tonumber(read()) or 3
    
    write("Spacing between turtles [10]: ")  
    local spacing = tonumber(read()) or 10
    
    write("Starting turtle ID [101]: ")
    local startId = tonumber(read()) or 101
    
    print()
    print("Deploying " .. count .. " turtles with " .. spacing .. " block spacing...")
    
    local deployed = 0
    for i = 1, count do
        print()
        print("Turtle " .. i .. "/" .. count)
        print("Move forward " .. ((i-1) * spacing) .. " blocks and press Enter...")
        read()
        
        if deployTurtleAtPosition("down", "advanced") then
            deployed = deployed + 1
            
            -- Try to configure if we have rednet
            local currentId = startId + i - 1
            configureTurtle(currentId, {
                fuel = 1500,
                program = "quarry", 
                autostart = false
            })
            
            print("✓ Turtle " .. i .. " deployed (ID: " .. currentId .. ")")
        else
            print("✗ Turtle " .. i .. " deployment failed")
        end
    end
    
    print()
    print("Fleet deployment complete!")
    print("Deployed: " .. deployed .. "/" .. count)
    
    if deployed > 0 then
        print()
        print("To start mining:")
        for i = 1, deployed do
            local id = startId + i - 1
            print("rednet.send(" .. id .. ", {command=\"START\"})")
        end
    end
end

print("eHydra Turtle Deployer v1.0")
print("===========================")
print()
print("1. Deploy single Advanced Mining Turtle")
print("2. Setup Advanced Wireless Chunky Turtle")  
print("3. Deploy Mining Fleet")
print("4. List inventory turtles")
print()

write("Choice [1-4]: ")
local choice = tonumber(read()) or 1

if choice == 1 then
    print()
    deployTurtleAtPosition("down", "advanced")
    
elseif choice == 2 then
    print()
    setupWirelessChunkyTurtle()
    
elseif choice == 3 then
    print()
    deployMiningFleet()
    
elseif choice == 4 then
    print()
    print("Turtles in inventory:")
    print("====================")
    local found = false
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and (item.name:find("turtle") or item.name:find("computer")) then
            print("Slot " .. slot .. ": " .. item.name .. " x" .. item.count)
            found = true
        end
    end
    if not found then
        print("No turtles found in inventory")
    end
    
else
    print("Invalid choice")
end
