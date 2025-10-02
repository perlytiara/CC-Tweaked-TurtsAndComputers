-- download.lua - Install eDig system in eDig folder
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

-- Create eDig directory if it doesn't exist
if not fs.exists("eDig") then
  fs.makeDir("eDig")
end

local success = 0

-- Download all files to eDig directory
for name, url in pairs(files) do
  if downloadFile(url, "eDig/" .. name) then
    success = success + 1
  end
end

-- Setup startup file for turtles (in root directory)
if turtle then
  if downloadFile(files.startup, "startup") then
    success = success + 1
  end
else
  print("- startup (not a turtle)")
end

print("Installed " .. success .. " files")

if turtle then
  print("Turtle setup complete!")
  print("Run 'eDig/client' to start listening for jobs")
  print("Or run 'eDig/edig dig <height> <length> <width> [place] [segment] [shape]' directly")
  print("Run 'eDig/update' to update all files")
else
  print("Computer setup complete!")
  print("Run 'eDig/multi' to send jobs to turtles")
  print("Run 'eDig/update' to update all files")
end