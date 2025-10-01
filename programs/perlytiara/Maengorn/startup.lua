-- Startup script for newly deployed turtles
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