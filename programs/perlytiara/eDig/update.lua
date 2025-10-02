-- update.lua - Update eDig system (deletes and redownloads)
print("eDig Update System")
print("Updating all eDig files...")

local files = {
  edig = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/edig.lua",
  client = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/client.lua",
  multi = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/multi.lua",
  startup = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/startup.lua",
  update = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/update.lua"
}

local function deleteAndDownload(url, filename)
  print("Updating " .. filename .. "...")
  
  -- Delete existing file if it exists
  if fs.exists(filename) then
    fs.delete(filename)
    print("  Deleted old " .. filename)
  end
  
  -- Download new file
  local result = shell.run("wget", url, filename)
  if result then
    print("✓ " .. filename .. " updated")
    return true
  else
    print("✗ Failed to update " .. filename)
    return false
  end
end

local success = 0

-- Update all files in current directory (eDig folder)
for name, url in pairs(files) do
  local filename = name
  if deleteAndDownload(url, filename) then
    success = success + 1
  end
end

-- Update startup file in root directory
if turtle then
  if deleteAndDownload(files.startup, "../startup") then
    success = success + 1
  end
end

print("\nUpdate complete!")
print("Updated " .. success .. " files")
print("All eDig files are now up to date!")
print("Files are organized in the eDig/ directory")