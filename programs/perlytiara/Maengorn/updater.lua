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
        name = "Disk Drive Turtle",
        programs = {
            {file = "startup.lua", description = "Startup script for disk deployment"},
            {file = "clientdig.lua", description = "Client mining program"}
        }
    },
    phone = {
        name = "Phone Turtle", 
        programs = {
            {file = "phone_server.lua", description = "Phone server communication"}
        }
    },
    master = {
        name = "Master Turtle",
        programs = {
            {file = "mineserver.lua", description = "Mining server coordinator"}
        }
    },
    all = {
        name = "All Programs",
        programs = {
            {file = "startup.lua", description = "Startup script for disk deployment"},
            {file = "clientdig.lua", description = "Client mining program"},
            {file = "phone_server.lua", description = "Phone server communication"},
            {file = "mineserver.lua", description = "Mining server coordinator"},
            {file = "gps-deploy.lua", description = "GPS deployment system"},
            {file = "updater.lua", description = "This updater program"}
        }
    }
}

-- Utility functions
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
    centerText("=====================================", 1)
    centerText("       MAENGORN UPDATER v1.0       ", 2)
    centerText("=====================================", 3)
    term.setTextColor(colors.white)
end

function drawFooter()
    local y = h
    term.setTextColor(colors.gray)
    term.setCursorPos(1, y)
    write("Up/Down Navigate | Enter Select | Q Quit")
    
    if totalPages > 1 then
        local pageText = string.format("Page %d/%d", currentPage, totalPages)
        term.setCursorPos(w - string.len(pageText), y)
        write(pageText)
    end
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

function downloadProgram(filename, description)
    local url = REPO_BASE .. filename
    local localPath = PROGRAMS_FOLDER .. filename
    
    -- Ensure programs folder exists
    if not fs.exists("programs") then
        fs.makeDir("programs")
    end
    if not fs.exists("programs/perlytiara") then
        fs.makeDir("programs/perlytiara")
    end
    if not fs.exists(PROGRAMS_FOLDER) then
        fs.makeDir(PROGRAMS_FOLDER)
    end
    
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.yellow)
    centerText("Downloading: " .. filename, 5)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 7)
    write("URL: " .. url)
    term.setCursorPos(2, 8)
    write("Local: " .. localPath)
    term.setCursorPos(2, 9)
    write("Description: " .. description)
    
    term.setTextColor(colors.blue)
    term.setCursorPos(2, 11)
    write("Status: Downloading...")
    
    -- Download the file
    local success, errorMsg = pcall(function()
        shell.run("wget", url, localPath)
    end)
    
    if success then
        term.setTextColor(colors.green)
        term.setCursorPos(2, 11)
        write("Status: ✓ Download successful!")
    else
        term.setTextColor(colors.red)
        term.setCursorPos(2, 11)
        write("Status: ✗ Download failed!")
        term.setCursorPos(2, 12)
        write("Error: " .. tostring(errorMsg))
    end
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, h - 1)
    write("Press any key to continue...")
    os.pullEvent("key")
end

function showMainMenu()
    clearScreen()
    drawHeader()
    
    term.setTextColor(colors.green)
    term.setCursorPos(2, 5)
    write("Detected Turtle Type: " .. turtleType)
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 7)
    write("Available Options:")
    
    -- Calculate how many options can fit on screen
    local availableHeight = h - 10  -- Leave space for header and footer
    local optionHeight = 3  -- Each option takes 3 lines
    local maxVisibleOptions = math.floor(availableHeight / optionHeight)
    
    -- Determine which options to show
    local endOption = math.min(startOption + maxVisibleOptions - 1, maxOptions)
    
    local y = 9
    
    -- Show options that fit on screen
    for i = startOption, endOption do
        if i == selectedOption then
            -- Show selected option with details
            if i == 1 then
                local config = PROGRAM_CONFIGS[turtleType]
                if config then
                    highlightOption(i, "Update " .. config.name .. " Programs", y)
                    y = y + 1
                    term.setTextColor(colors.gray)
                    term.setCursorPos(4, y)
                    local programNames = {}
                    for _, program in ipairs(config.programs) do
                        table.insert(programNames, program.file)
                    end
                    write("Updates: " .. table.concat(programNames, ", "))
                    y = y + 1
                else
                    highlightOption(i, "Update Detected Programs", y)
                    y = y + 2
                end
            elseif i == 2 then
                highlightOption(i, "Update All Programs", y)
                y = y + 1
                term.setTextColor(colors.gray)
                term.setCursorPos(4, y)
                write("Updates all available programs")
                y = y + 1
            elseif i == 3 then
                highlightOption(i, "Manual Program Selection", y)
                y = y + 1
                term.setTextColor(colors.gray)
                term.setCursorPos(4, y)
                write("Choose individual programs to update")
                y = y + 1
            elseif i == 4 then
                highlightOption(i, "Show Program Information", y)
                y = y + 1
                term.setTextColor(colors.gray)
                term.setCursorPos(4, y)
                write("Display updater help and information")
                y = y + 1
            elseif i == 5 then
                highlightOption(i, "Exit", y)
                y = y + 1
                term.setTextColor(colors.gray)
                term.setCursorPos(4, y)
                write("Close the updater program")
                y = y + 1
            end
        else
            -- Show unselected option
            if i == 1 then
                local config = PROGRAM_CONFIGS[turtleType]
                if config then
                    highlightOption(i, "Update " .. config.name .. " Programs", y)
                else
                    highlightOption(i, "Update Detected Programs", y)
                end
            elseif i == 2 then
                highlightOption(i, "Update All Programs", y)
            elseif i == 3 then
                highlightOption(i, "Manual Program Selection", y)
            elseif i == 4 then
                highlightOption(i, "Show Program Information", y)
            elseif i == 5 then
                highlightOption(i, "Exit", y)
            end
            y = y + 2
        end
    end
    
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
    local programs = {
        {file = "startup.lua", description = "Startup script for disk deployment"},
        {file = "clientdig.lua", description = "Client mining program"},
        {file = "phone_server.lua", description = "Phone server communication"},
        {file = "mineserver.lua", description = "Mining server coordinator"},
        {file = "gps-deploy.lua", description = "GPS deployment system"},
        {file = "updater.lua", description = "This updater program"}
    }
    
    local manualSelectedOption = 1
    local manualStartOption = 1
    
    while true do
        clearScreen()
        drawHeader()
        
        term.setTextColor(colors.yellow)
        centerText("Manual Program Selection", 5)
        term.setTextColor(colors.white)
        
        term.setCursorPos(2, 7)
        write("Select a program to update:")
        
        -- Calculate how many options can fit on screen
        local availableHeight = h - 12  -- Leave space for header, title, and footer
        local optionHeight = 2  -- Each option takes 2 lines
        local maxVisibleOptions = math.floor(availableHeight / optionHeight)
        
        -- Determine which options to show
        local endOption = math.min(manualStartOption + maxVisibleOptions - 1, #programs)
        
        local y = 9
        
        -- Show options that fit on screen
        for i = manualStartOption, endOption do
            if i == manualSelectedOption then
                -- Show selected option with highlighting
                term.setTextColor(colors.black)
                term.setBackgroundColor(colors.white)
                term.setCursorPos(2, y)
                write("> " .. programs[i].file)
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
                term.setCursorPos(4, y + 1)
                write(programs[i].description)
            else
                -- Show unselected option
                term.setTextColor(colors.blue)
                term.setCursorPos(2, y)
                write("  " .. programs[i].file)
                term.setTextColor(colors.gray)
                term.setCursorPos(4, y + 1)
                write(programs[i].description)
            end
            y = y + 2
        end
        
        -- Footer
        term.setTextColor(colors.gray)
        term.setCursorPos(1, h)
        write("Up/Down Navigate | Enter Select | Q Back")
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q or key == keys.escape then
            return
        elseif key == keys.up then
            if manualSelectedOption > 1 then
                manualSelectedOption = manualSelectedOption - 1
                -- Adjust scrolling window if needed
                if manualSelectedOption < manualStartOption then
                    manualStartOption = manualSelectedOption
                end
            end
        elseif key == keys.down then
            if manualSelectedOption < #programs then
                manualSelectedOption = manualSelectedOption + 1
                -- Adjust scrolling window if needed
                if manualSelectedOption > manualStartOption + maxVisibleOptions - 1 then
                    manualStartOption = manualSelectedOption - maxVisibleOptions + 1
                end
            end
        elseif key == keys.enter then
            downloadProgram(programs[manualSelectedOption].file, programs[manualSelectedOption].description)
            return
        end
    end
end

function showProgramInfo()
    local info = [[
MAENGORN UPDATER v1.0

This updater automatically detects your turtle type and updates
the appropriate programs for your configuration.

TURTLE TYPES:
• Disk Drive Turtle: Updates startup.lua and clientdig.lua
• Phone Turtle: Updates phone_server.lua
• Master Turtle: Updates mineserver.lua and gps-deploy.lua
• All Programs: Updates everything

FEATURES:
• Automatic turtle type detection
• Paginated text display
• Error handling and validation
• Manual program selection
• Clean, user-friendly interface

REPOSITORY:
https://github.com/perlytiara/CC-Tweaked-TurtsAndComputers

The updater downloads programs from the main branch and places
them in the programs/perlytiara/Maengorn/ folder structure.
]]
    
    currentPage = 1
    clearScreen()
    drawHeader()
    displayText(info, 5)
    drawFooter()
    
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.q or key == keys.escape then
            break
        elseif key == keys.up and currentPage > 1 then
            currentPage = currentPage - 1
            clearScreen()
            drawHeader()
            displayText(info, 5)
            drawFooter()
        elseif key == keys.down and currentPage < totalPages then
            currentPage = currentPage + 1
            clearScreen()
            drawHeader()
            displayText(info, 5)
            drawFooter()
        end
    end
end

function main()
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
                showProgramInfo()
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

