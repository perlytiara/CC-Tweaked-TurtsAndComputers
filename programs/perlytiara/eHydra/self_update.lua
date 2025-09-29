-- eHydra Self-Update System
-- Auto-updates all eHydra programs from GitHub repository

local baseUrl = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eHydra/"

-- eHydra programs to auto-update
local eHydraPrograms = {
    "autoupdater.lua",
    "batch_updater.lua", 
    "init.lua",
    "turtle_deployer.lua",
    "startup.lua",
    "self_update.lua",  -- Self-update capability
    "README.md"
}

local function backupFile(filepath)
    if fs.exists(filepath) then
        local backupPath = filepath .. ".backup"
        if fs.exists(backupPath) then
            fs.delete(backupPath)
        end
        fs.copy(filepath, backupPath)
        print("  📦 Backed up: " .. filepath)
        return true
    end
    return false
end

local function restoreFile(filepath)
    local backupPath = filepath .. ".backup"
    if fs.exists(backupPath) then
        if fs.exists(filepath) then
            fs.delete(filepath)
        end
        fs.copy(backupPath, filepath)
        fs.delete(backupPath)
        print("  🔄 Restored: " .. filepath)
        return true
    end
    return false
end

local function cleanupBackups()
    print("Cleaning up backup files...")
    for _, filename in ipairs(eHydraPrograms) do
        local backupPath = filename .. ".backup"
        if fs.exists(backupPath) then
            fs.delete(backupPath)
            print("  🗑️  Removed backup: " .. backupPath)
        end
    end
end

print("eHydra Self-Update System v1.0")
print("==============================")
print("This will update all eHydra programs from GitHub")
print()

write("Proceed with update? (y/n) [y]: ")
local confirm = string.lower(read())
if confirm == "n" then
    print("Update cancelled.")
    return
end

print()
print("Starting eHydra self-update...")
print("Repository: " .. baseUrl)
print("Files to update: " .. #eHydraPrograms)
print()

local success = 0
local failed = 0
local backups = {}

-- Create backups first
print("📦 Creating backups...")
for _, filename in ipairs(eHydraPrograms) do
    if backupFile(filename) then
        table.insert(backups, filename)
    end
end

print()
print("📥 Downloading updates...")

for i, filename in ipairs(eHydraPrograms) do
    print("[" .. i .. "/" .. #eHydraPrograms .. "] Updating " .. filename .. "...")
    
    local url = baseUrl .. filename
    local response = http.get(url)
    
    if response then
        -- Delete existing file
        if fs.exists(filename) then
            fs.delete(filename)
        end
        
        -- Write new content
        local file = fs.open(filename, "w")
        if file then
            file.write(response.readAll())
            file.close()
            response.close()
            print("  ✅ " .. filename .. " updated successfully")
            success = success + 1
        else
            print("  ❌ " .. filename .. " - failed to write file")
            -- Restore from backup
            restoreFile(filename)
            failed = failed + 1
        end
    else
        print("  ❌ " .. filename .. " - download failed")
        -- Restore from backup  
        restoreFile(filename)
        failed = failed + 1
    end
end

print()
print("📊 Update Summary")
print("================")
print("✅ Successfully updated: " .. success .. " files")
print("❌ Failed updates: " .. failed .. " files")

if failed == 0 then
    print("🎉 All updates completed successfully!")
    cleanupBackups()
else
    print("⚠️  Some updates failed - backups preserved")
    print("   To restore all backups, run: restore_backups")
end

print()
if success > 0 then
    print("🔄 eHydra system has been updated!")
    print("   Restart any running eHydra programs to use new versions")
    
    -- Offer to restart
    print()
    write("Restart eHydra startup menu? (y/n) [n]: ")
    local restart = string.lower(read())
    if restart == "y" then
        print("Restarting eHydra...")
        shell.run("startup")
    end
else
    print("No files were updated.")
end
