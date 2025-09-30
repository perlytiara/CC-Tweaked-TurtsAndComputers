-- MAENGORN TURTLE AUTO-DEPLOYMENT
-- Automatically installs and runs programs from floppy disk

local function copyProgramsFromDisk()
    if not fs.exists("disk/") then
        print("No floppy disk found!")
        return false
    end
    
    local programs = {
        "clientdig.lua",
        "startup.lua", 
        "phone_server.lua",
        "mineserver.lua",
        "gps-deploy.lua",
        "updater.lua"
    }
    
    local installed = 0
    for _, program in ipairs(programs) do
        if fs.exists("disk/" .. program) then
            fs.copy("disk/" .. program, program)
            installed = installed + 1
            print("Installed: " .. program)
        end
    end
    
    print("Installed " .. installed .. " programs from disk")
    return installed > 0
end

local function detectTurtleType()
    -- Check if we have a disk drive (disk drive turtles have disk access)
    if fs.exists("disk/") then
        return "disk_drive"
    end
    
    -- Check if we have mining server programs (master turtle)
    if fs.exists("mineserver.lua") then
        return "master"
    end
    
    -- Check if we have phone server programs (phone turtle)
    if fs.exists("phone_server.lua") then
        return "phone"
    end
    
    return "unknown"
end

-- Main deployment logic
print("=== MAENGORN TURTLE DEPLOYMENT ===")

-- Copy programs from floppy disk
if copyProgramsFromDisk() then
    print("Programs copied successfully!")
else
    print("No programs found on disk or disk missing!")
end

-- Detect turtle type and run appropriate program
local turtleType = detectTurtleType()
print("Detected turtle type: " .. turtleType)

if turtleType == "disk_drive" then
    print("Starting clientdig...")
    if fs.exists("clientdig.lua") then
        shell.run("clientdig")
    else
        print("ERROR: clientdig.lua not found!")
    end
elseif turtleType == "master" then
    print("Starting mineserver...")
    if fs.exists("mineserver.lua") then
        shell.run("mineserver")
    else
        print("ERROR: mineserver.lua not found!")
    end
elseif turtleType == "phone" then
    print("Phone turtle ready - waiting for commands...")
    print("Use: phone_server <width> <height> <depth>")
else
    print("Unknown turtle type - manual operation required")
end
    
    