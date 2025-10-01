-- Startup script for newly deployed turtles

-- Try to equip wireless modem if available
function equipModem()
    print("Checking for wireless modem...")
    
    -- Check if already equipped
    if peripheral.find("modem") then
        print("Modem already equipped")
        return true
    end
    
    -- Try to find modem in inventory
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            if item.name:find("wireless_modem") then
                print("Found modem in slot " .. slot .. ", equipping...")
                turtle.select(slot)
                turtle.equipLeft()
                if peripheral.find("modem") then
                    print("Modem equipped on left")
                    return true
                end
                turtle.equipRight()
                if peripheral.find("modem") then
                    print("Modem equipped on right")
                    return true
                end
            end
        end
    end
    
    print("WARNING: No wireless modem found!")
    return false
end

-- Try to equip modem first
equipModem()

function findDiskDrive()
    -- Check all sides for a disk drive
    local sides = {"left", "right", "front", "back", "top", "bottom"}
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "drive" then
            if peripheral.call(side, "isDiskPresent") then
                print("Found disk on " .. side)
                return side
            end
        end
    end
    return nil
end

if not fs.exists("/clientdig") then
    -- First boot - look for disk drive
    print("First boot - searching for disk drive...")
    local diskSide = findDiskDrive()
    
    if not diskSide then
        print("ERROR: No disk drive found!")
        print("Please place a disk drive with files adjacent to turtle")
        os.sleep(5)
        os.reboot()
        return
    end
    
    -- Copy files from disk
    if fs.exists("disk/clientdig") then
        fs.copy("disk/clientdig", "/clientdig")
        print("Copied clientdig from disk")
    else
        print("ERROR: No clientdig found on disk!")
        os.sleep(5)
        return
    end
    
    if fs.exists("disk/startup") then
        fs.copy("disk/startup", "/startup")
        print("Copied startup from disk")
    end
    
    print("Setup complete, rebooting...")
    os.sleep(1)
    os.reboot()
else
    -- Files already installed, run the client
    print("Starting client...")
    shell.run("clientdig")
end