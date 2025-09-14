-- Turtle Manager Startup Script
-- This runs automatically when the turtle starts up
-- It provides quick access to turtle management tools

local function printStartupBanner()
    term.clear()
    term.setCursorPos(1, 1)
    print("========================================")
    print("        TURTLE STARTUP MANAGER")
    print("========================================")
    print()
    
    local label = os.getComputerLabel() or "Unlabeled"
    local id = os.getComputerID()
    
    print("Turtle: " .. label .. " (ID: " .. id .. ")")
    print("Status: Ready for VS Code connection")
    print()
end

local function showQuickMenu()
    print("Quick Actions:")
    print("1. Connect to VS Code")
    print("2. File Sync Utility") 
    print("3. Program Deployer")
    print("4. Run existing program")
    print("5. Exit to shell")
    print()
end

local function runExistingProgram()
    print("Available Programs:")
    print("==================")
    
    local programs = {}
    
    -- Check programs directory
    if fs.exists("programs") then
        for _, file in ipairs(fs.list("programs")) do
            if not fs.isDir("programs/" .. file) and file:sub(-4) == ".lua" then
                table.insert(programs, "programs/" .. file)
            end
        end
    end
    
    -- Check root directory for .lua files
    for _, file in ipairs(fs.list("")) do
        if not fs.isDir(file) and file:sub(-4) == ".lua" and file ~= "startup" then
            table.insert(programs, file)
        end
    end
    
    if #programs == 0 then
        print("No programs found.")
        return
    end
    
    for i, program in ipairs(programs) do
        print(i .. ". " .. program)
    end
    
    print()
    write("Select program to run (1-" .. #programs .. "): ")
    local choice = tonumber(read())
    
    if choice and choice >= 1 and choice <= #programs then
        local selected = programs[choice]
        print("Running: " .. selected)
        print("===================")
        shell.run(selected)
    else
        print("Invalid selection!")
    end
end

local function main()
    printStartupBanner()
    
    while true do
        showQuickMenu()
        write("Select option (1-5): ")
        local choice = read()
        
        if choice == "1" then
            shell.run("turtle-manager/turtle-connector")
        elseif choice == "2" then
            shell.run("turtle-manager/file-sync")
        elseif choice == "3" then
            shell.run("turtle-manager/program-deployer")
        elseif choice == "4" then
            runExistingProgram()
        elseif choice == "5" then
            print("Exiting to shell...")
            break
        else
            print("Invalid option. Please try again.")
        end
        
        print()
        print("Press any key to continue...")
        os.pullEvent("key")
        printStartupBanner()
    end
end

-- Run the startup manager
main()
