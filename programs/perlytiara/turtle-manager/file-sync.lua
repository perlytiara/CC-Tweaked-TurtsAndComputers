-- File Sync Utility for Turtle Management
-- This script helps sync files between the turtle and VS Code workspace

local function printBanner()
    term.clear()
    term.setCursorPos(1, 1)
    print("========================================")
    print("       TURTLE FILE SYNC UTILITY")
    print("========================================")
    print()
end

local function listFiles(directory)
    local files = {}
    local dirs = {}
    
    if fs.exists(directory) then
        for _, file in ipairs(fs.list(directory)) do
            local path = directory .. "/" .. file
            if fs.isDir(path) then
                table.insert(dirs, file)
            else
                table.insert(files, file)
            end
        end
    end
    
    return files, dirs
end

local function displayFileTree(directory, prefix, maxDepth, currentDepth)
    currentDepth = currentDepth or 0
    if currentDepth >= maxDepth then return end
    
    local files, dirs = listFiles(directory)
    
    -- Display directories first
    for _, dir in ipairs(dirs) do
        local path = directory .. "/" .. dir
        print(prefix .. "📁 " .. dir)
        displayFileTree(path, prefix .. "  ", maxDepth, currentDepth + 1)
    end
    
    -- Display files
    for _, file in ipairs(files) do
        print(prefix .. "📄 " .. file)
    end
end

local function getFileSize(filepath)
    if not fs.exists(filepath) then return 0 end
    
    local file = fs.open(filepath, "r")
    if not file then return 0 end
    
    local content = file.readAll()
    file.close()
    
    return #content
end

local function formatSize(bytes)
    if bytes < 1024 then
        return bytes .. " B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

local function showFileInfo()
    print("Current Turtle File System:")
    print("==========================")
    print()
    
    -- Show root directory
    displayFileTree("", "", 3)
    
    print()
    print("Key directories:")
    print("• programs/ - Your turtle programs")
    print("• startup/ - Programs that run on startup")
    print("• logs/ - Log files")
    print()
end

local function backupFiles()
    print("Creating backup of turtle files...")
    
    local backupDir = "backup_" .. os.time()
    fs.makeDir(backupDir)
    
    local function copyDirectory(src, dst)
        fs.makeDir(dst)
        for _, file in ipairs(fs.list(src)) do
            local srcPath = src .. "/" .. file
            local dstPath = dst .. "/" .. file
            
            if fs.isDir(srcPath) then
                copyDirectory(srcPath, dstPath)
            else
                local srcFile = fs.open(srcPath, "r")
                local dstFile = fs.open(dstPath, "w")
                
                if srcFile and dstFile then
                    dstFile.write(srcFile.readAll())
                    srcFile.close()
                    dstFile.close()
                end
            end
        end
    end
    
    -- Backup important directories
    local dirsToBackup = {"programs", "startup"}
    for _, dir in ipairs(dirsToBackup) do
        if fs.exists(dir) then
            copyDirectory(dir, backupDir .. "/" .. dir)
            print("Backed up: " .. dir)
        end
    end
    
    print("Backup created in: " .. backupDir)
end

local function showDiskUsage()
    print("Disk Usage Information:")
    print("======================")
    print()
    
    local function getDirectorySize(dir)
        local total = 0
        if not fs.exists(dir) then return 0 end
        
        for _, file in ipairs(fs.list(dir)) do
            local path = dir .. "/" .. file
            if fs.isDir(path) then
                total = total + getDirectorySize(path)
            else
                total = total + getFileSize(path)
            end
        end
        return total
    end
    
    local programsSize = getDirectorySize("programs")
    local startupSize = getDirectorySize("startup")
    local totalSize = programsSize + startupSize
    
    print("Programs directory: " .. formatSize(programsSize))
    print("Startup directory: " .. formatSize(startupSize))
    print("Total used: " .. formatSize(totalSize))
    print()
end

local function main()
    printBanner()
    
    while true do
        print("Available operations:")
        print("1. Show file system tree")
        print("2. Show disk usage")
        print("3. Create backup")
        print("4. Exit")
        print()
        
        write("Select option (1-4): ")
        local choice = read()
        
        if choice == "1" then
            showFileInfo()
        elseif choice == "2" then
            showDiskUsage()
        elseif choice == "3" then
            backupFiles()
        elseif choice == "4" then
            print("Goodbye!")
            break
        else
            print("Invalid option. Please try again.")
        end
        
        print()
        print("Press any key to continue...")
        os.pullEvent("key")
        printBanner()
    end
end

-- Run the main function
main()
