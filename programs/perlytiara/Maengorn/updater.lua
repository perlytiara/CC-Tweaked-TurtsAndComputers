-- MAENGORN UPDATER
-- Auto-updates programs based on turtle type detection
-- Supports disk drive, phone, and master turtle configurations

local w, h = term.getSize()
local currentPage = 1
local totalPages = 1
local lines = {}
local turtleType = "unknown"
local selectedOption = 1
local maxOptions = 5
local startOption = 1
local optionsPerPage = 5
local installPath = "programs/perlytiara/Maengorn/"
local useExtension = true
local settingsFile = ".maengorn_settings"

-- Colors for better UI
local colors = {
    white = colors.white,
    gray = colors.gray,
    black = colors.black,
    blue = colors.blue,
    green = colors.green,
    red = colors.red,
    yellow = colors.yellow,
    orange = colors.orange
}

-- Repository configuration
local REPO_BASE = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/Maengorn/"
local PROGRAMS_FOLDER = "programs/perlytiara/Maengorn/"

-- Program definitions by turtle type
local PROGRAM_CONFIGS = {
    disk_drive = {
        name = "Disk Drive",
        programs = {
            {name = "startup", file = "startup.lua", description = "Startup script"},
            {name = "clientdig", file = "clientdig.lua", description = "Client mining"}
        }
    },
    phone = {
        name = "Phone Turtle", 
        programs = {
            {name = "phone_server", file = "phone_server.lua", description = "Phone server"}
        }
    },
    master = {
        name = "Master Turtle",
        programs = {
            {name = "mineserver", file = "mineserver.lua", description = "Mining server"}
        }
    },
    all = {
        name = "All Programs",
        programs = {
            {name = "startup", file = "startup.lua", description = "Startup script"},
            {name = "clientdig", file = "clientdig.lua", description = "Client mining"},
            {name = "phone_server", file = "phone_server.lua", description = "Phone server"},
            {name = "mineserver", file = "mineserver.lua", description = "Mining server"},
            {name = "gps-deploy", file = "gps-deploy.lua", description = "GPS deployment"},
            {name = "updater", file = "updater.lua", description = "This updater"}
        }
    }
}

-- Utility functions
function loadSettings()
    if fs.exists(settingsFile) then
        local file = fs.open(settingsFile, "r")
        if file then
            local content = file.readAll()
            file.close()
            
            -- Parse settings from file
            for line in content:gmatch("[^\r\n]+") do
                if line:match("^installPath=") then
                    installPath = line:match("installPath=(.+)")
                elseif line:match("^useExtension=") then
                    useExtension = line:match("useExtension=(.+)") == "true"
                end
            end
        end
    end
end

function saveSettings()
    local file = fs.open(settingsFile, "w")
    if file then
        file.write("installPath=" .. installPath .. "\n")
        file.write("useExtension=" .. tostring(useExtension) .. "\n")
        file.close()
    end
end

function detectTurtleType()
    -- Check if we have a disk drive (disk drive turtles have disk access)
    if fs.exists("disk/") then
        return "disk_drive"
    end
    
    -- Check if we have mining server programs (master turtle)
    if fs.exists("mineserver.lua") or fs.exists(PROGRAMS_FOLDER .. "mineserver.lua") then
        return "master"
    end
    
    -- Check if we have phone server programs (phone turtle)
    if fs.exists("phone_server.lua") or fs.exists(PROGRAMS_FOLDER .. "phone_server.lua") then
        return "phone"
    end
    
    -- Default to all if we can't determine
    return "all"
end

function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

function centerText(text, y)
    local x = math.floor((w - string.len(text)) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    write(text)
end

function drawHeader()
    term.setTextColor(colors.blue)
    centerText("===================", 1)
    centerText(" MAENGORN UPDATER ", 2)
    centerText("===================", 3)
    term.setTextColor(colors.white)
end

function drawFooter()
    local y = h
    term.setTextColor(colors.gray)
    term.setCursorPos(1, y)
    write("Arrows:Navigate | Enter:Select | Q:Quit")
end

function highlightOption(optionNum, text, y)
    if optionNum == selectedOption then
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.white)
        term.setCursorPos(2, y)
        write("> " .. text)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
    else
        term.setTextColor(colors.blue)
        term.setCursorPos(2, y)
        write("  " .. text)
    end
end

function splitText(text, width)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        if string.len(currentLine .. " " .. word) <= width then
            if currentLine == "" then
                currentLine = word
            else
                currentLine = currentLine .. " " .. word
            end
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                table.insert(lines, word)
            end
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

function displayText(text, startY)
    lines = splitText(text, w - 2)
    totalPages = math.max(1, math.ceil(#lines / (h - startY - 2)))
    
    local startLine = (currentPage - 1) * (h - startY - 2) + 1
    local endLine = math.min(startLine + (h - startY - 2) - 1, #lines)
    
    for i = startLine, endLine do
        if lines[i] then
            term.setCursorPos(2, startY + (i - startLine))
            write(lines[i])
        end
    end
end

function downloadProgram(programInfo, description)
    local url = REPO_BASE .. programInfo.file
    local finalPath = installPath .. programInfo.name
    if useExtension then
        finalPath = finalPath .. ".lua"
    end
    
    -- Ensure install folder exists
    local pathParts = {}
    for part in installPath:gmatch("[^/]+") do
        table.insert(pathParts, part)
    end
    
    local currentPath = ""
    for _, part in ipairs(pathParts) do
        currentPath = currentPath .. part .. "/"
        if not fs.exists(currentPath) then
            fs.makeDir(currentPath)
        end
    end
    
    -- Remove old file if it exists
    if fs.exists(finalPath) then
        fs.delete(finalPath)
    end
    
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Downloading: " .. programInfo.name, 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("From: " .. url)
    term.setCursorPos(2, 8)
    write("To: " .. finalPath)
    term.setCursorPos(2, 9)
    write("Desc: " .. description)
    
    term.setTextColor(colors.blue)
    term.setCursorPos(2, 11)
    write("Status: Downloading...")
    
    -- Download the file
    local success, errorMsg = pcall(function()
        shell.run("wget", url, finalPath)
    end)
    
    if success then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 11)
        write("Status: Success!")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 11)
        write("Status: Failed!")
        term.setCursorPos(2, 12)
        write("Error: " .. tostring(errorMsg))
    end
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, h - 1)
    write("Press any key...")
    os.pullEvent("key")
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, 5)
    write("Type: " .. turtleType)
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 6)
    write("Options:")
    
    local y = 8
    local config = PROGRAM_CONFIGS[turtleType]
    
    -- Option 1: Update detected turtle type programs
    if config then
        highlightOption(1, "Update " .. config.name, y)
    else
        highlightOption(1, "Update Detected", y)
    end
    y = y + 1
    
    -- Option 2: Update all programs
    highlightOption(2, "Update All", y)
    y = y + 1
    
    -- Option 3: Manual selection
    highlightOption(3, "Manual Select", y)
    y = y + 1
    
    -- Option 4: Settings
    highlightOption(4, "Settings", y)
    y = y + 1
    
    -- Option 5: Exit
    highlightOption(5, "Exit", y)
    
    drawFooter()
end

function updatePrograms(config)
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Updating " .. config.name .. " Programs", 5)
    term.setTextColor(colors.white)
    
    for i, program in ipairs(config.programs) do
        term.setCursorPos(2, 7 + (i - 1) * 2)
        write(string.format("[%d/%d] %s", i, #config.programs, program.file))
        
        downloadProgram(program.file, program.description)
    end
    
    clearScreen()
    drawHeader()
    term.setTextColor(colors.green)
    centerText("All programs updated successfully!", 5)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 7)
    write("Press any key to return to main menu...")
    os.pullEvent("key")
end

function showManualSelection()
    local programs = PROGRAM_CONFIGS.all.programs
    local manualSelectedOption = 1
    
    while true do
        clearScreen()
        drawHeader()
        
        term.setTextColor(colors.yellow)
        centerText("Manual Select", 5)
        term.setTextColor(colors.white)
        
        local y = 7
        
        -- Show all programs (compact for small screens)
        for i, program in ipairs(programs) do
            if i == manualSelectedOption then
                -- Show selected option with highlighting
                term.setTextColor(colors.black)
                term.setBackgroundColor(colors.white)
                term.setCursorPos(2, y)
                write("> " .. program.name)
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
            else
                -- Show unselected option
                term.setTextColor(colors.blue)
                term.setCursorPos(2, y)
                write("  " .. program.name)
            end
            y = y + 1
        end
        
        -- Footer
        term.setTextColor(colors.gray)
        term.setCursorPos(1, h)
        write("Arrows:Navigate | Enter:Select | Q:Back")
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q or key == keys.escape then
            return
        elseif key == keys.up then
            if manualSelectedOption > 1 then
                manualSelectedOption = manualSelectedOption - 1
            end
        elseif key == keys.down then
            if manualSelectedOption < #programs then
                manualSelectedOption = manualSelectedOption + 1
            end
        elseif key == keys.enter then
            downloadProgram(programs[manualSelectedOption], programs[manualSelectedOption].description)
            return
        end
    end
end

function showSettings()
    local settingsSelected = 1
    local maxSettings = 3
    
    while true do
        clearScreen()
        drawHeader()
        
        term.setTextColor(colors.yellow)
        centerText("Settings", 5)
        term.setTextColor(colors.white)
        
        term.setCursorPos(2, 7)
        write("Install Path: " .. installPath)
        term.setCursorPos(2, 8)
        write("Use .lua extension: " .. (useExtension and "Yes" or "No"))
        term.setCursorPos(2, 9)
        write("Current: " .. turtleType)
        
        local y = 11
        if settingsSelected == 1 then
            highlightOption(1, "Change Install Path", y)
        else
            term.setTextColor(colors.blue)
            term.setCursorPos(2, y)
            write("Change Install Path")
        end
        y = y + 1
        
        if settingsSelected == 2 then
            highlightOption(2, "Toggle .lua Extension", y)
        else
            term.setTextColor(colors.blue)
            term.setCursorPos(2, y)
            write("Toggle .lua Extension")
        end
        y = y + 1
        
        if settingsSelected == 3 then
            highlightOption(3, "Back to Menu", y)
        else
            term.setTextColor(colors.blue)
            term.setCursorPos(2, y)
            write("Back to Menu")
        end
        
        term.setTextColor(colors.gray)
        term.setCursorPos(1, h)
        write("Arrows:Navigate | Enter:Select | Q:Back")
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q or key == keys.escape then
            return
        elseif key == keys.up then
            if settingsSelected > 1 then
                settingsSelected = settingsSelected - 1
            end
        elseif key == keys.down then
            if settingsSelected < maxSettings then
                settingsSelected = settingsSelected + 1
            end
        elseif key == keys.enter then
            if settingsSelected == 1 then
                clearScreen()
                drawHeader()
                term.setTextColor(colors.white)
                term.setCursorPos(2, 5)
                write("Enter install path:")
                term.setCursorPos(2, 6)
                write("(e.g., programs/myfolder/ or just /)")
                term.setCursorPos(2, 8)
                write("Current: " .. installPath)
                term.setCursorPos(2, 10)
                write("New path: ")
                local newPath = read()
                if newPath and newPath ~= "" then
                    installPath = newPath
                    if not installPath:match("/$") then
                        installPath = installPath .. "/"
                    end
                    saveSettings()
                end
            elseif settingsSelected == 2 then
                useExtension = not useExtension
                saveSettings()
            elseif settingsSelected == 3 then
                return
            end
        end
    end
end

function main()
    -- Load saved settings
    loadSettings()
    
    -- Detect turtle type
    turtleType = detectTurtleType()
    
    while true do
        showMainMenu()
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q or key == keys.escape then
            clearScreen()
            term.setCursorPos(1, 1)
            return
        elseif key == keys.up then
            if selectedOption > 1 then
                selectedOption = selectedOption - 1
                -- Adjust scrolling window if needed
                local availableHeight = h - 10
                local optionHeight = 3
                local maxVisibleOptions = math.floor(availableHeight / optionHeight)
                
                if selectedOption < startOption then
                    startOption = selectedOption
                end
                
                showMainMenu()
            end
        elseif key == keys.down then
            if selectedOption < maxOptions then
                selectedOption = selectedOption + 1
                -- Adjust scrolling window if needed
                local availableHeight = h - 10
                local optionHeight = 3
                local maxVisibleOptions = math.floor(availableHeight / optionHeight)
                
                if selectedOption > startOption + maxVisibleOptions - 1 then
                    startOption = selectedOption - maxVisibleOptions + 1
                end
                
                showMainMenu()
            end
        elseif key == keys.enter then
            if selectedOption == 1 then
                local config = PROGRAM_CONFIGS[turtleType]
                if config then
                    updatePrograms(config)
                end
            elseif selectedOption == 2 then
                updatePrograms(PROGRAM_CONFIGS.all)
            elseif selectedOption == 3 then
                showManualSelection()
            elseif selectedOption == 4 then
                showSettings()
            elseif selectedOption == 5 then
                clearScreen()
                term.setCursorPos(1, 1)
                return
            end
        end
    end
end

-- Start the updater
main()

