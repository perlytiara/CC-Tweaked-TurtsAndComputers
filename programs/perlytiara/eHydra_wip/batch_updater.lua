-- eHydra Batch Updater
-- Updates multiple programs from a configuration file or predefined list

local baseUrl = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/"

-- Predefined programs to update - organized by folders
local programs = {
    -- eHydra Management System (ALL FILES)
    {url = baseUrl .. "eHydra/autoupdater.lua", folder = "eHydra", name = "autoupdater"},
    {url = baseUrl .. "eHydra/batch_updater.lua", folder = "eHydra", name = "batch_updater"},
    {url = baseUrl .. "eHydra/init.lua", folder = "eHydra", name = "init"},
    {url = baseUrl .. "eHydra/turtle_deployer.lua", folder = "eHydra", name = "turtle_deployer"},
    {url = baseUrl .. "eHydra/startup.lua", folder = "eHydra", name = "startup"},
    {url = baseUrl .. "eHydra/self_update.lua", folder = "eHydra", name = "self_update"},
    {url = baseUrl .. "eHydra/restore_backups.lua", folder = "eHydra", name = "restore_backups"},
    {url = baseUrl .. "eHydra/turtle_client.lua", folder = "eHydra", name = "turtle_client"},
    {url = baseUrl .. "eHydra/mining_setup.lua", folder = "eHydra", name = "mining_setup"},
    {url = baseUrl .. "eHydra/launcher.lua", folder = "eHydra", name = "launcher"},
    {url = baseUrl .. "eHydra/README.md", folder = "eHydra", name = "README"},
    
    -- Stairs programs
    {url = baseUrl .. "stairs/multi.lua", folder = "stairs", name = "multi"},
    {url = baseUrl .. "stairs/client.lua", folder = "stairs", name = "client"},
    {url = baseUrl .. "stairs/stairs.lua", folder = "stairs", name = "stairs"},
    {url = baseUrl .. "stairs/download.lua", folder = "stairs", name = "download"},
    {url = baseUrl .. "stairs/startup.lua", folder = "stairs", name = "startup"},
    
    -- Mining programs
    {url = baseUrl .. "tClear/tClear.lua", folder = "tClear", name = "tClear"},
    {url = baseUrl .. "tClear/tClearChunky.lua", folder = "tClear", name = "tClearChunky"},
    {url = baseUrl .. "tClear/AdvancedMiningTurtle.lua", folder = "tClear", name = "AdvancedMiningTurtle"},
    {url = baseUrl .. "tClear/AdvancedChunkyTurtle.lua", folder = "tClear", name = "AdvancedChunkyTurtle"},
    
    -- Quarry programs
    {url = baseUrl .. "quarry/quarry.lua", folder = "quarry", name = "quarry"},
    {url = baseUrl .. "quarry/quarry_multi.lua", folder = "quarry", name = "quarry_multi"},
    
    -- GPS programs
    {url = baseUrl .. "gps/gps.lua", folder = "gps", name = "gps"},
    {url = baseUrl .. "gps/gps_host.lua", folder = "gps", name = "gps_host"},
    
    -- Epic Mining programs
    {url = baseUrl .. "EpicMiningTurtle/EpicMiningTurtle_remote.lua", folder = "EpicMiningTurtle", name = "EpicMiningTurtle_remote"},
    
    -- Platform and building programs
    {url = baseUrl .. "tPlatform/tPlatform_fixed.lua", folder = "tPlatform", name = "tPlatform_fixed"},
    {url = baseUrl .. "dome_tunnels/dome_tunnels.lua", folder = "dome_tunnels", name = "dome_tunnels"},
    {url = baseUrl .. "room_carver.lua", folder = "building", name = "room_carver"},
    {url = baseUrl .. "entrance_carver.lua", folder = "building", name = "entrance_carver"},
}

-- Function to ensure directory exists
local function ensureDirectory(path)
    if not fs.exists(path) then
        fs.makeDir(path)
        return true
    end
    return false
end

-- Ensure programs directory exists
ensureDirectory("programs")

-- Count unique folders for display
local folders = {}
for _, program in ipairs(programs) do
    folders[program.folder] = true
end
local folderCount = 0
for _ in pairs(folders) do
    folderCount = folderCount + 1
end

print("eHydra Batch Updater v2.0")
print("=========================")
print("Repository: " .. baseUrl)
print("Programs to update: " .. #programs .. " across " .. folderCount .. " folders")
print("📁 Organized by program categories")
print()

-- Ask for confirmation
write("Proceed with batch update? (y/n) [y]: ")
local confirm = string.lower(read())
if confirm == "n" then
    print("Update cancelled.")
    return
end

print()
print("🚀 Starting batch update...")

local success = 0
local failed = 0
local startTime = os.clock()

for i, program in ipairs(programs) do
    local folderPath = "programs/" .. program.folder
    local fileExtension = program.name == "README" and ".md" or ".lua"
    local programPath = folderPath .. "/" .. program.name .. fileExtension
    
    print("[" .. i .. "/" .. #programs .. "] " .. program.folder .. "/" .. program.name .. fileExtension .. "...")
    
    -- Ensure folder exists
    if ensureDirectory(folderPath) then
        print("  📁 Created folder: " .. program.folder)
    end
    
    -- Delete existing file
    if fs.exists(programPath) then
        fs.delete(programPath)
    end
    
    -- Download with timeout handling
    local response = http.get(program.url, nil, nil, 10) -- 10 second timeout
    if response then
        -- Check if response is valid
        local content = response.readAll()
        response.close()
        
        if content and content ~= "" then
            local file = fs.open(programPath, "w")
            if file then
                file.write(content)
                file.close()
                print("  ✅ " .. program.folder .. "/" .. program.name .. fileExtension .. " - downloaded " .. #content .. " bytes")
                success = success + 1
            else
                print("  ❌ " .. program.name .. " - failed to write file")
                failed = failed + 1
            end
        else
            print("  ❌ " .. program.name .. " - empty response")
            failed = failed + 1
        end
    else
        print("  ❌ " .. program.name .. " - download failed/timeout")
        failed = failed + 1
    end
    
    -- Small delay to be nice to the server
    sleep(0.1)
end

local endTime = os.clock()
local duration = endTime - startTime

print()
print("📊 Batch Update Complete!")
print("========================")
print("✅ Successfully updated: " .. success .. " programs")
print("❌ Failed updates: " .. failed .. " programs") 
print("⏱️  Total time: " .. string.format("%.1f", duration) .. " seconds")
print("📁 Programs organized in: programs/<folder>/<program>.lua")

if success > 0 then
    print()
    print("🎉 Updated programs are ready to use!")
    print("   📁 Program structure:")
    
    -- Show folder organization
    local folderList = {}
    for folder in pairs(folders) do
        table.insert(folderList, folder)
    end
    table.sort(folderList)
    
    for _, folder in ipairs(folderList) do
        print("      programs/" .. folder .. "/")
        -- Show programs in this folder
        for _, program in ipairs(programs) do
            if program.folder == folder then
                print("         " .. program.name .. ".lua")
            end
        end
    end
    
    print()
    print("   💡 Usage examples:")
    print("      programs/eHydra/startup.lua")
    print("      programs/quarry/quarry.lua")
    print("      programs/stairs/multi.lua")
end

if failed > 0 then
    print()
    print("⚠️  Some downloads failed. This could be due to:")
    print("   • Network connectivity issues")
    print("   • File not found on repository") 
    print("   • Server timeout")
    print("   Try running batch_updater again later")
end

print()
print("🔄 All programs organized by category!")
print("   Navigate to programs/<folder>/ to find specific programs")
