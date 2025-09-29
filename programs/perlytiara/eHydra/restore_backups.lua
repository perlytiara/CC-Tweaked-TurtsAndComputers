-- eHydra Backup Restoration System
-- Restores eHydra programs from backup files

local eHydraPrograms = {
    "autoupdater.lua",
    "batch_updater.lua", 
    "init.lua",
    "turtle_deployer.lua",
    "startup.lua",
    "self_update.lua",
    "README.md"
}

print("eHydra Backup Restoration v1.0")
print("==============================")

-- Check for available backups
local backupsFound = {}
for _, filename in ipairs(eHydraPrograms) do
    local backupPath = filename .. ".backup"
    if fs.exists(backupPath) then
        table.insert(backupsFound, filename)
    end
end

if #backupsFound == 0 then
    print("❌ No backup files found.")
    print("Backups are only created during updates.")
    return
end

print("📦 Found " .. #backupsFound .. " backup file(s):")
for i, filename in ipairs(backupsFound) do
    print("  " .. i .. ". " .. filename)
end

print()
write("Restore all backups? (y/n) [n]: ")
local confirm = string.lower(read())

if confirm ~= "y" then
    print("Restoration cancelled.")
    return
end

print()
print("🔄 Restoring backup files...")

local restored = 0
for _, filename in ipairs(backupsFound) do
    local backupPath = filename .. ".backup"
    
    print("Restoring " .. filename .. "...")
    
    -- Delete current file if it exists
    if fs.exists(filename) then
        fs.delete(filename)
    end
    
    -- Restore from backup
    fs.copy(backupPath, filename)
    fs.delete(backupPath)
    
    print("  ✅ " .. filename .. " restored")
    restored = restored + 1
end

print()
print("🎉 Restoration complete!")
print("✅ Restored " .. restored .. " files")
print("🗑️  Backup files have been removed")
print()
print("eHydra has been restored to previous versions.")
