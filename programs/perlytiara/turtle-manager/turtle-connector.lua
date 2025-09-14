-- Turtle Connector Script
-- This script helps connect turtles to CraftOS-PC Remote
-- Run this on any turtle to establish a connection to VS Code

local function printBanner()
    term.clear()
    term.setCursorPos(1, 1)
    print("========================================")
    print("    TURTLE CONNECTOR FOR VS CODE")
    print("========================================")
    print()
end

local function getTurtleInfo()
    local label = os.getComputerLabel() or "Unlabeled"
    local id = os.getComputerID()
    return label, id
end

local function checkRequirements()
    local hasModem = false
    local sides = {"left", "right", "top", "bottom", "front", "back"}
    
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) then
            local p = peripheral.wrap(side)
            if p and p.isWirelessModem then
                hasModem = true
                break
            end
        end
    end
    
    return hasModem
end

local function main()
    printBanner()
    
    local label, id = getTurtleInfo()
    print("Turtle Label: " .. label)
    print("Turtle ID: " .. id)
    print()
    
    -- Check for wireless modem
    if not checkRequirements() then
        print("ERROR: No wireless modem found!")
        print("Please attach a wireless modem to any side of this turtle.")
        print("Press any key to exit...")
        os.pullEvent("key")
        return
    end
    
    print("Wireless modem detected!")
    print()
    print("To connect this turtle to VS Code:")
    print("1. Install the CraftOS-PC extension in VS Code")
    print("2. Click the CraftOS-PC button in the sidebar")
    print("3. Click 'Connect to Remote'")
    print("4. Copy the connection command from VS Code")
    print("5. Paste it here and press Enter")
    print()
    print("Alternatively, visit: https://remote.craftos-pc.cc")
    print()
    
    while true do
        write("Connection command: ")
        local command = read()
        
        if command and command ~= "" then
            print("Executing connection command...")
            print("Command: " .. command)
            print()
            
            -- Execute the command
            local success, result = pcall(function()
                shell.run(command)
            end)
            
            if success then
                print("Connection established!")
                print("You can now manage this turtle from VS Code.")
                break
            else
                print("Connection failed: " .. tostring(result))
                print("Please try again or check your command.")
            end
        else
            print("Please enter a valid connection command.")
        end
        
        print()
    end
end

-- Run the main function
main()
