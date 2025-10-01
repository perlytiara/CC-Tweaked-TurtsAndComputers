--{program="startup",version="1.0",date="2024-12-19"}
---------------------------------------
-- CCommander Startup                 by AI Assistant
-- 2024-12-19, v1.0   Startup script for cCommander system
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Startup script for the cCommander system
-- Automatically launches the test_bootup system
-- Can be configured to launch other programs

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local cVersion = "v1.0"
local cPrgName = "CCommander Startup"
local blnDebugPrint = true

-- Startup configuration
local defaultProgram = "test_bootup"
local startupDelay = 2 -- seconds

---------------------------------------
---- UTILITY FUNCTIONS --------------- 
---------------------------------------
function debugPrint(message)
    if blnDebugPrint then
        print("[" .. cPrgName .. "] " .. message)
    end
end

function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

function centerText(text, y)
    local w, h = term.getSize()
    local x = math.floor((w - string.len(text)) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    write(text)
end

function showStartupMessage()
    clearScreen()
    
    term.setTextColor(colors.blue)
    centerText("===================", 1)
    centerText(" CCOMMANDER SYSTEM ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
    
    term.setTextColor(colors.green)
    centerText("Starting up...", 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("Version: " .. cVersion)
    term.setCursorPos(2, 8)
    write("Launching: " .. defaultProgram)
    
    for i = startupDelay, 1, -1 do
        term.setCursorPos(2, 10)
        write("Starting in " .. i .. " seconds...")
        sleep(1)
    end
    
    clearScreen()
end

function main()
    debugPrint("Starting " .. cPrgName .. " v" .. cVersion)
    
    showStartupMessage()
    
    -- Launch the default program
    debugPrint("Launching " .. defaultProgram)
    
    -- Check if the program exists
    local programPath = "programs/perlytiara/cCommander/" .. defaultProgram .. ".lua"
    if fs.exists(programPath) then
        shell.run(programPath)
    else
        clearScreen()
        term.setTextColor(colors.red)
        centerText("ERROR", 5)
        term.setTextColor(colors.white)
        term.setCursorPos(2, 7)
        write("Program not found: " .. programPath)
        term.setCursorPos(2, 8)
        write("Available programs:")
        
        -- List available programs
        local programs = {
            "test_bootup",
            "turtle_deployer", 
            "chest_manager",
            "autoupdater"
        }
        
        for i, program in ipairs(programs) do
            term.setCursorPos(4, 9 + i)
            write("- " .. program)
        end
        
        local w, h = term.getSize()
        term.setCursorPos(2, h - 1)
        write("Press any key to exit...")
        os.pullEvent("key")
    end
end

-- Start the system
main()
