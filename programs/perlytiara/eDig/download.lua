-- download.lua - Install eDig system
print("Installing eDig system...")

local files = {
  edig = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/edig.lua",
  client = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/client.lua",
  multi = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/multi.lua",
  startup = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/startup.lua",
  update = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/update.lua"
}

local function downloadFile(url, filename)
  print("Downloading " .. filename .. "...")
  local result = shell.run("wget", url, filename)
  if result then
    print("✓ " .. filename)
    return true
  else
    print("✗ Failed to download " .. filename)
    return false
  end
end

local success = 0

-- Download all files
for name, url in pairs(files) do
  if downloadFile(url, name) then
    success = success + 1
  end
end

print("Installed " .. success .. " files")

if turtle then
  print("Turtle setup complete!")
  print("Run 'client' to start listening for jobs")
  print("Or run 'edig dig <height> <length> <width> [place] [segment]' directly")
  print("Run 'update' to update all files")
else
  print("Computer setup complete!")
  print("Run 'multi' to send jobs to turtles")
  print("Run 'update' to update all files")
end