-- Test script to verify folder structure creation
-- This script tests the folder creation logic

print("Testing eHydra Folder Structure")
print("==============================")

-- Test folder creation function
local function ensureDirectory(path)
    if not fs.exists(path) then
        fs.makeDir(path)
        print("✅ Created: " .. path)
        return true
    else
        print("📁 Exists: " .. path)
        return false
    end
end

-- Test the folder structure
local testFolders = {
    "programs",
    "programs/eHydra", 
    "programs/stairs",
    "programs/quarry",
    "programs/tClear",
    "programs/gps"
}

print()
print("Creating test folder structure...")

for _, folder in ipairs(testFolders) do
    ensureDirectory(folder)
end

print()
print("Testing file path generation...")

-- Test file path generation
local testFiles = {
    {folder = "eHydra", name = "startup", ext = ".lua"},
    {folder = "eHydra", name = "README", ext = ".md"},
    {folder = "quarry", name = "quarry", ext = ".lua"},
    {folder = "stairs", name = "multi", ext = ".lua"}
}

for _, file in ipairs(testFiles) do
    local path = "programs/" .. file.folder .. "/" .. file.name .. file.ext
    print("📄 Path: " .. path)
end

print()
print("✅ Folder structure test complete!")
print("   All folders should be created in programs/ directory")


