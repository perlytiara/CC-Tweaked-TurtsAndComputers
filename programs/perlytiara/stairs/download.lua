-- download.lua - Install stairs system
print("Installing stairs system...")

local files = {
  stairs = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/stairs.lua",
  client = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/client.lua",
  multi = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/multi.lua",
  startup = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/startup.lua"
}

-- Download file using wget
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

-- Create programs directory if it doesn't exist
if not fs.exists("programs") then
  fs.makeDir("programs")
end

-- Download files to programs directory
local success = 0

if downloadFile(files.stairs, "programs/stairs") then
  success = success + 1
end

if downloadFile(files.client, "programs/client") then
  success = success + 1
end

if downloadFile(files.multi, "programs/multi") then
  success = success + 1
end

-- Setup startup file for turtles
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
  print("Run 'client' to start listening for jobs")
  print("Or run 'stairs <height> [up/down] [steps] [place]' directly")
else
  print("Computer setup complete!")
  print("Run 'multi' to send jobs to turtles")
end
