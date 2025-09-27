-- download.lua - Install stairs system
print("Installing stairs system...")

local files = {
  stairs = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/stairs.lua",
  client = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/client.lua",
  multi = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/multi.lua",
  startup = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/startup.lua"
}

-- For now, just copy from local files since we don't have URLs
local function copyFile(from, to)
  local source = fs.open(from, "r")
  if not source then
    print("Failed to read " .. from)
    return false
  end
  
  local content = source.readAll()
  source.close()
  
  local dest = fs.open(to, "w")
  if not dest then
    print("Failed to write " .. to)
    return false
  end
  
  dest.write(content)
  dest.close()
  return true
end

-- Create programs directory if it doesn't exist
if not fs.exists("programs") then
  fs.makeDir("programs")
end

-- Copy files to programs directory
local success = 0
if copyFile("stairs.lua", "programs/stairs") then
  print("✓ stairs")
  success = success + 1
end

if copyFile("client.lua", "programs/client") then
  print("✓ client")  
  success = success + 1
end

if copyFile("multi.lua", "programs/multi") then
  print("✓ multi")
  success = success + 1
end

-- Setup startup file for turtles
if turtle then
  if copyFile("startup.lua", "startup") then
    print("✓ startup (turtle)")
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
