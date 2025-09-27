-- eSlicer Phone Client
-- Remote control interface for eSlicer mining operations

local SERVER_PORT = 420
local PHONE_PORT = 69

local modem = peripheral.wrap("back") or peripheral.wrap("right") or peripheral.wrap("left")
if not modem then
    print("Error: No wireless modem found!")
    return
end

modem.open(PHONE_PORT)

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function getUserInput(prompt)
    write(prompt)
    return read()
end

function getNumberInput(prompt, min, max)
    while true do
        write(prompt)
        local input = tonumber(read())
        if input and input >= min and input <= max then
            return input
        else
            print(string.format("Please enter a number between %d and %d", min, max))
        end
    end
end

function showMainMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("eSlicer Remote Control v1.0")
    print("===========================")
    print()
    print("1. Start Mining Operation")
    print("2. Check Server Status")
    print("3. Emergency Stop")
    print("4. Exit")
    print()
end

function getMiningParameters()
    term.clear()
    term.setCursorPos(1, 1)
    print("eSlicer Mining Setup")
    print("===================")
    print()
    
    -- Get starting coordinates
    print("Starting coordinates (bottom-left corner):")
    local startX = getNumberInput("X coordinate: ", -30000000, 30000000)
    local startY = getNumberInput("Y coordinate: ", -64, 320)
    local startZ = getNumberInput("Z coordinate: ", -30000000, 30000000)
    
    print()
    print("Mining area dimensions:")
    local sizeX = getNumberInput("Width (X): ", 1, 1000)
    local sizeY = getNumberInput("Height (Y): ", 1, 256) 
    local sizeZ = getNumberInput("Depth (Z): ", 1, 1000)
    
    print()
    print("Settings:")
    local segmentation = getNumberInput("Turtle segment size (5-50): ", 5, 50)
    
    return {
        start = {x = startX, y = startY, z = startZ},
        size = {x = sizeX, y = sizeY, z = sizeZ},
        segmentation = segmentation
    }
end

function startMiningOperation()
    local params = getMiningParameters()
    
    term.clear()
    term.setCursorPos(1, 1)
    print("eSlicer Mining Operation")
    print("=======================")
    print()
    print(string.format("Start: %d %d %d", params.start.x, params.start.y, params.start.z))
    print(string.format("Size: %dx%dx%d", params.size.x, params.size.y, params.size.z))
    print(string.format("Segmentation: %d", params.segmentation))
    print()
    
    local volume = params.size.x * params.size.y * params.size.z
    local segments = math.ceil(params.size.x / params.segmentation) * math.ceil(params.size.z / params.segmentation)
    
    print(string.format("Total volume: %d blocks", volume))
    print(string.format("Turtle pairs needed: %d", segments))
    print()
    
    write("Confirm mining operation? (y/N): ")
    local confirm = read()
    
    if string.lower(confirm) == "y" or string.lower(confirm) == "yes" then
        print("Sending mining request to server...")
        
        local message = string.format("%d %d %d %d %d %d", 
            params.start.x, params.start.y, params.start.z,
            params.size.x, params.size.y, params.size.z)
        
        modem.transmit(SERVER_PORT, PHONE_PORT, message)
        
        print("Mining request sent!")
        print("Check server turtle for deployment status.")
        print()
        write("Press any key to return to menu...")
        read()
    else
        print("Operation cancelled.")
        os.sleep(2)
    end
end

function checkServerStatus()
    term.clear()
    term.setCursorPos(1, 1)
    print("Server Status Check")
    print("==================")
    print()
    print("Sending status request...")
    
    modem.transmit(SERVER_PORT, PHONE_PORT, "STATUS_REQUEST")
    
    -- Wait for response with timeout
    local timer = os.startTimer(5)
    while true do
        local event, param1, param2, param3, param4, param5 = os.pullEvent()
        
        if event == "modem_message" then
            print("Server responded: " .. tostring(param4))
            break
        elseif event == "timer" and param1 == timer then
            print("No response from server (timeout)")
            print("Server may be offline or busy")
            break
        end
    end
    
    print()
    write("Press any key to return to menu...")
    read()
end

function emergencyStop()
    term.clear()
    term.setCursorPos(1, 1)
    print("Emergency Stop")
    print("==============")
    print()
    print("WARNING: This will attempt to stop all mining")
    print("operations immediately. Turtles may be left")
    print("in mining areas.")
    print()
    write("Are you sure? (y/N): ")
    
    local confirm = read()
    if string.lower(confirm) == "y" or string.lower(confirm) == "yes" then
        print("Sending emergency stop signal...")
        modem.transmit(SERVER_PORT, PHONE_PORT, "EMERGENCY_STOP")
        print("Emergency stop sent!")
    else
        print("Emergency stop cancelled.")
    end
    
    print()
    write("Press any key to return to menu...")
    read()
end

-- Main program loop
print("Starting eSlicer Phone Client...")
print("Searching for server...")

while true do
    showMainMenu()
    write("Choose option (1-4): ")
    local choice = read()
    
    if choice == "1" then
        startMiningOperation()
    elseif choice == "2" then
        checkServerStatus()
    elseif choice == "3" then
        emergencyStop()
    elseif choice == "4" then
        print("Goodbye!")
        break
    else
        print("Invalid option. Press any key to try again...")
        read()
    end
end
