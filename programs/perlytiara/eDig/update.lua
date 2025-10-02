-- update.lua - Quick update system for eDig
print("eDig Update System")
print("Updating all eDig files...")

local files = {
  edig = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/edig.lua",
  client = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/client.lua",
  multi = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/multi.lua",
  startup = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/startup.lua",
  download = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/download.lua",
  update = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/update.lua"
}

local function downloadFile(url, filename)
  print("Updating " .. filename .. "...")
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

-- Update all files
for name, url in pairs(files) do
  if downloadFile(url, name) then
    success = success + 1
  end
end

print("\nUpdate complete!")
print("Updated " .. success .. " files")
print("All eDig files are now up to date!")
