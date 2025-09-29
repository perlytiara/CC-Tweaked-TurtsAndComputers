-- eHydra Batch Updater
-- Updates multiple programs from a configuration file or predefined list

local baseUrl = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/"

-- Predefined programs to update
local programs = {
    -- eHydra Management System
    {url = baseUrl .. "eHydra/autoupdater.lua", name = "ehydra-autoupdater"},
    {url = baseUrl .. "eHydra/batch_updater.lua", name = "ehydra-batch-updater"},
    {url = baseUrl .. "eHydra/init.lua", name = "ehydra-init"},
    {url = baseUrl .. "eHydra/turtle_deployer.lua", name = "ehydra-deployer"},
    {url = baseUrl .. "eHydra/startup.lua", name = "ehydra-startup"},
    {url = baseUrl .. "eHydra/self_update.lua", name = "ehydra-self-update"},
    {url = baseUrl .. "eHydra/restore_backups.lua", name = "ehydra-restore"},
    
    -- Stairs programs
    {url = baseUrl .. "stairs/multi.lua", name = "stairs-multi"},
    {url = baseUrl .. "stairs/client.lua", name = "stairs-client"},
    {url = baseUrl .. "stairs/stairs.lua", name = "stairs"},
    {url = baseUrl .. "stairs/download.lua", name = "stairs-download"},
    {url = baseUrl .. "stairs/startup.lua", name = "stairs-startup"},
    
    -- Mining programs
    {url = baseUrl .. "tClear/tClear.lua", name = "tclear"},
    {url = baseUrl .. "tClear/tClearChunky.lua", name = "tclear-chunky"},
    {url = baseUrl .. "tClear/AdvancedMiningTurtle.lua", name = "advanced-mining"},
    {url = baseUrl .. "tClear/AdvancedChunkyTurtle.lua", name = "advanced-chunky"},
    {url = baseUrl .. "quarry/quarry.lua", name = "quarry"},
    {url = baseUrl .. "quarry/quarry_multi.lua", name = "quarry-multi"},
    
    -- Utility programs  
    {url = baseUrl .. "gps/gps.lua", name = "gps"},
    {url = baseUrl .. "gps/gps_host.lua", name = "gps-host"},
    {url = baseUrl .. "EpicMiningTurtle/EpicMiningTurtle_remote.lua", name = "epic-mining"},
    
    -- Platform and building
    {url = baseUrl .. "tPlatform/tPlatform_fixed.lua", name = "tplatform"},
    {url = baseUrl .. "dome_tunnels/dome_tunnels.lua", name = "dome-tunnels"},
    {url = baseUrl .. "room_carver.lua", name = "room-carver"},
    {url = baseUrl .. "entrance_carver.lua", name = "entrance-carver"},
}

-- Ensure programs directory exists
if not fs.exists("programs") then
    fs.makeDir("programs")
    print("📁 Created programs directory")
end

print("eHydra Batch Updater v2.0")
print("=========================")
print("Repository: " .. baseUrl)
print("Programs to update: " .. #programs)
print("📦 Includes: eHydra System + Turtle Programs")
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
    print("[" .. i .. "/" .. #programs .. "] " .. program.name .. "...")
    
    -- Delete existing file
    local programPath = "programs/" .. program.name .. ".lua"
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
                print("  ✅ " .. program.name .. " - downloaded " .. #content .. " bytes")
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
print("📁 Programs saved to: programs/ directory")

if success > 0 then
    print()
    print("🎉 Updated programs are ready to use!")
    print("   📂 eHydra programs: ehydra-* prefix")
    print("   🐢 Turtle programs: direct names")
    print("   💡 Example: ehydra-startup, quarry, stairs-multi")
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
print("🔄 Note: eHydra system has been updated!")
print("   Use 'ehydra-startup' to access the main menu")
