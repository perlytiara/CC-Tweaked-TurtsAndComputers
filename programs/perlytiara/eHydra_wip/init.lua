-- eHydra Initialization System
-- Manages advanced mining turtle deployment and initialization

local function findModem()
    for _, side in pairs(rs.getSides()) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
            return side
        end
    end
    return nil
end

local function deployTurtle(turtleType, position)
    print("Deploying " .. turtleType .. " at position " .. position .. "...")
    
    -- Look for turtle in inventory
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            if item.name == "computercraft:turtle_advanced" or 
               item.name == "computercraft:" .. turtleType then
                turtle.select(slot)
                
                -- Place the turtle
                if turtle.place() then
                    print("✓ Turtle deployed successfully")
                    return true
                else
                    print("✗ Failed to place turtle - check space")
                    return false
                end
            end
        end
    end
    
    print("✗ No " .. turtleType .. " found in inventory")
    return false
end

local function initializeTurtle(id, program)
    print("Initializing turtle " .. id .. " with " .. program .. "...")
    
    -- Send initialization command
    rednet.send(id, {
        command = "INIT",
        program = program,
        autostart = true
    })
    
    -- Wait for response
    local senderId, response = rednet.receive(5)
    if senderId == id and response and response.status == "READY" then
        print("✓ Turtle " .. id .. " initialized successfully")
        return true
    else
        print("✗ Turtle " .. id .. " initialization failed or timed out")
        return false
    end
end

local function setupGPS()
    print("Setting up GPS system...")
    
    -- Try to get GPS coordinates
    local x, y, z = gps.locate()
    if x then
        print("✓ GPS location: " .. x .. ", " .. y .. ", " .. z)
        return true
    else
        print("⚠ GPS not available - manual positioning required")
        return false
    end
end

print("eHydra Initialization System v1.0")
print("=================================")
print()

-- Check for modem
local modemSide = findModem()
if modemSide then
    rednet.open(modemSide)
    print("✓ Modem found on " .. modemSide .. " side")
else
    print("⚠ No modem found - limited functionality")
end

print()
print("Select operation:")
print("1. Deploy Advanced Mining Turtle")
print("2. Deploy Advanced Wireless Chunky Turtle")
print("3. Initialize existing turtle")
print("4. Setup GPS system")
print("5. Full deployment sequence")
print()

write("Choice [1-5]: ")
local choice = tonumber(read()) or 1

if choice == 1 then
    print()
    print("Deploying Advanced Mining Turtle...")
    deployTurtle("turtle_advanced", "current")
    
elseif choice == 2 then
    print()
    print("Deploying Advanced Wireless Chunky Turtle...")
    deployTurtle("turtle_advanced", "current")
    
    -- Additional setup for chunky turtles
    print("Configuring chunky loading...")
    -- This would require specific chunky turtle setup
    
elseif choice == 3 then
    if not modemSide then
        print("Error: Modem required for turtle initialization")
        return
    end
    
    print()
    write("Turtle ID: ")
    local id = tonumber(read())
    
    write("Program to load [quarry]: ")
    local program = read()
    if program == "" then program = "quarry" end
    
    initializeTurtle(id, program)
    
elseif choice == 4 then
    setupGPS()
    
elseif choice == 5 then
    print()
    print("Full Deployment Sequence")
    print("=======================")
    
    -- Setup GPS
    setupGPS()
    
    print()
    write("Number of turtles to deploy [1]: ")
    local count = tonumber(read()) or 1
    
    write("Turtle type (mining/chunky) [mining]: ")
    local turtleType = read()
    if turtleType == "" then turtleType = "mining" end
    
    write("Mining program [quarry]: ")
    local program = read()
    if program == "" then program = "quarry" end
    
    print()
    print("Deploying " .. count .. " " .. turtleType .. " turtle(s)...")
    
    for i = 1, count do
        print()
        print("Deploying turtle " .. i .. "/" .. count .. "...")
        
        if deployTurtle("turtle_advanced", i) then
            -- Wait a moment for turtle to boot
            sleep(2)
            
            if modemSide then
                -- Try to initialize the turtle
                -- This would require the turtle to have a known ID or auto-discovery
                print("Turtle deployed - manual initialization may be required")
            end
        end
    end
    
    print()
    print("Deployment sequence complete!")
    
else
    print("Invalid choice")
end

print()
print("eHydra initialization finished.")
