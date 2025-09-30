-- eHydra Turtle Client
-- Receives commands and executes programs from eHydra deployment system

local CLIENT_PORT = 0
local SERVER_PORT = 420
local EHYDRA_PROTOCOL = "ehydra"

-- Find and open modem
local modem = peripheral.find("modem")
if not modem then
    print("❌ No modem found - wireless functionality disabled")
else
    rednet.open(peripheral.getName(modem))
    print("📡 Wireless modem enabled")
end

-- Send deployment confirmation
if modem then
    print("📤 Sending deployment confirmation...")
    rednet.broadcast("TURTLE_DEPLOYED", EHYDRA_PROTOCOL)
end

-- Utility functions
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function checkFuel()
    if turtle.getFuelLevel() < 50 then
        print("⛽ Low fuel, attempting refuel...")
        for slot = 1, 16 do
            turtle.select(slot)
            if turtle.refuel() then
                print("✅ Refueled successfully")
                return true
            end
        end
        print("❌ No fuel available")
        return false
    end
    return true
end

-- Main command processing loop
print("🐢 eHydra Turtle Client v1.0")
print("============================")
print("Turtle ID: " .. os.getComputerID())

-- Get GPS coordinates if available
local x, y, z = gps.locate(5, false)
if x then
    print("📍 GPS Location: " .. x .. ", " .. y .. ", " .. z)
else
    print("📍 GPS: Not available")
end

print("⏳ Listening for commands...")

-- Command processing
while true do
    if modem then
        local senderId, message, protocol = rednet.receive(EHYDRA_PROTOCOL, 1)
        
        if message then
            print("📨 Received command from " .. senderId)
            
            if type(message) == "table" then
                local command = message.command
                
                if command == "RUN" then
                    local program = message.program or "quarry"
                    local args = message.args or ""
                    
                    print("🚀 Running program: " .. program .. " " .. args)
                    
                    if fs.exists(program) then
                        shell.run(program .. " " .. args)
                    else
                        print("❌ Program not found: " .. program)
                        rednet.send(senderId, {status = "ERROR", message = "Program not found"}, EHYDRA_PROTOCOL)
                    end
                    
                elseif command == "STATUS" then
                    local status = {
                        id = os.getComputerID(),
                        fuel = turtle.getFuelLevel(),
                        position = {x = x, y = y, z = z},
                        inventory = {}
                    }
                    
                    for slot = 1, 16 do
                        local item = turtle.getItemDetail(slot)
                        if item then
                            status.inventory[slot] = {name = item.name, count = item.count}
                        end
                    end
                    
                    rednet.send(senderId, {status = "OK", data = status}, EHYDRA_PROTOCOL)
                    print("📊 Status sent to " .. senderId)
                    
                elseif command == "REFUEL" then
                    if checkFuel() then
                        rednet.send(senderId, {status = "OK", fuel = turtle.getFuelLevel()}, EHYDRA_PROTOCOL)
                    else
                        rednet.send(senderId, {status = "ERROR", message = "No fuel available"}, EHYDRA_PROTOCOL)
                    end
                    
                elseif command == "STOP" then
                    print("🛑 Stop command received")
                    rednet.send(senderId, {status = "OK", message = "Stopping"}, EHYDRA_PROTOCOL)
                    break
                    
                else
                    print("❓ Unknown command: " .. tostring(command))
                    rednet.send(senderId, {status = "ERROR", message = "Unknown command"}, EHYDRA_PROTOCOL)
                end
            else
                print("📝 Text message: " .. tostring(message))
            end
        end
    end
    
    -- Small delay to prevent CPU overload
    sleep(0.1)
end

print("🐢 eHydra Turtle Client shutting down...")
if modem then
    rednet.close()
end
