-- edig.lua - All-in-one eDig system
-- Usage: edig [command] [args...]
-- Commands: dig, multi, install, client, help

local args = {...}

-- Check if we're on a turtle
local function hasTurtle()
  return pcall(function() return turtle.getFuelLevel() end)
end

-- Movement helpers
local function df() while turtle.detect() do turtle.dig() end end
local function du() while turtle.detectUp() do turtle.digUp() end end
local function dd() while turtle.detectDown() do turtle.digDown() end end
local function gf()
  while not turtle.forward() do
    if turtle.detect() then turtle.dig() end
    turtle.attack()
  end
end
local function gu()
  while not turtle.up() do
    if turtle.detectUp() then turtle.digUp() end
    turtle.attackUp()
  end
end
local function gd()
  while not turtle.down() do
    if turtle.detectDown() then turtle.digDown() end
    turtle.attackDown()
  end
end

-- Resource scanning
local function scanInventory()
  local fuel = 0
  local blocks = 0
  local fuelSlots = {}
  local blockSlots = {}
  
  for i = 1, 16 do
    local count = turtle.getItemCount(i)
    if count > 0 then
      turtle.select(i)
      local isFuel = turtle.refuel(0)
      if isFuel then
        fuel = fuel + count
        table.insert(fuelSlots, i)
      else
        blocks = blocks + count
        table.insert(blockSlots, i)
      end
    end
  end
  
  return {
    fuel = fuel,
    blocks = blocks,
    fuelSlots = fuelSlots,
    blockSlots = blockSlots
  }
end

-- Fuel management
local function refuel(target)
  if turtle.getFuelLevel() == "unlimited" then return true end
  
  local current = turtle.getSelectedSlot()
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      while turtle.getItemCount(i) > 0 and turtle.getFuelLevel() < target do
        if not turtle.refuel(1) then break end
      end
      if turtle.getFuelLevel() >= target then break end
    end
  end
  turtle.select(current)
  
  if turtle.getFuelLevel() < target then
    print("Need fuel! Current: " .. turtle.getFuelLevel())
    print("Add coal/charcoal to any slot")
    while turtle.getFuelLevel() < target do
      sleep(1)
      for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
          turtle.select(i)
          if turtle.refuel(1) then break end
        end
      end
    end
  end
  return true
end

-- Find block slot for placement
local function findBlockSlot()
  for i = 1, 16 do
    local count = turtle.getItemCount(i)
    if count > 0 then
      turtle.select(i)
      local isFuel = turtle.refuel(0)
      if not isFuel then return i end
    end
  end
  return nil
end

-- Place floor
local function placeFloor()
  if not turtle.detectDown() then
    local slot = findBlockSlot()
    if slot then
      turtle.select(slot)
      turtle.placeDown()
    end
  end
end

-- Tunnel digging function
local function digTunnelSlice(height, width, shouldPlaceFloor)
  -- Dig the slice in front of turtle
  -- First, dig the height
  for h = 1, height - 1 do
    du()
    if h < height - 1 then gu() end
  end
  
  -- Dig forward
  df()
  gf()
  if shouldPlaceFloor then placeFloor() end
  
  -- Return to base level
  for h = 1, height - 1 do gd() end
  
  -- Dig the width (side to side)
  for w = 1, width - 1 do
    turtle.turnLeft()
    df()
    gf()
    if shouldPlaceFloor then placeFloor() end
    
    -- Dig up for height
    for h = 1, height - 1 do
      du()
      if h < height - 1 then gu() end
    end
    
    -- Return to base
    for h = 1, height - 1 do gd() end
    
    turtle.turnRight()
  end
  
  -- Return to starting position
  for w = 1, width - 1 do
    turtle.turnLeft()
    gf()
    turtle.turnRight()
  end
end

-- Dig command
local function digCommand()
  if not hasTurtle() then
    print("Turtle required for digging!")
    return
  end
  
  local height = 3
  local length = 32
  local width = 3
  local autoPlace = false
  local segment = nil
  
  -- Parse arguments
  if #args >= 2 then
    height = math.max(1, tonumber(args[2]) or 3)
    for i = 3, #args do
      local arg = string.lower(args[i])
      local num = tonumber(args[i])
      if num then
        if i == 3 then
          length = math.max(1, num)
        elseif i == 4 then
          width = math.max(1, num)
        elseif i == 5 then
          segment = num
        end
      elseif arg == "place" then
        autoPlace = true
      end
    end
  else
    -- Interactive prompts
    term.clear()
    term.setCursorPos(1, 1)
    print("eDig - Straight Tunnel Digger")
    
    local resources = scanInventory()
    print("Resources: " .. resources.fuel .. " fuel, " .. resources.blocks .. " blocks")
    
    write("Tunnel height (blocks) [3]: ")
    local h = read()
    if h ~= "" then height = math.max(1, tonumber(h) or 3) end
    
    write("Tunnel length (blocks) [32]: ")
    local l = read()
    if l ~= "" then length = math.max(1, tonumber(l) or 32) end
    
    write("Tunnel width (blocks) [3]: ")
    local w = read()
    if w ~= "" then width = math.max(1, tonumber(w) or 3) end
    
    write("Place floor blocks? (y/n) [n]: ")
    local place = string.lower(read())
    autoPlace = (place == "y" or place == "yes")
    
    write("Segment number (for multi-turtle) [none]: ")
    local seg = read()
    if seg ~= "" then segment = tonumber(seg) end
  end
  
  -- Resource check and planning
  local resources = scanInventory()
  print("Digging straight tunnel")
  print("Dimensions: " .. length .. "x" .. width .. "x" .. height)
  if segment then
    print("Segment: " .. segment)
  end
  
  print("Resources: " .. resources.fuel .. " fuel, " .. resources.blocks .. " blocks")
  
  -- Initial fuel check
  local fuelNeeded = length * (width + height) * 2
  if resources.fuel * 80 < fuelNeeded then
    print("Warning: May need more fuel")
  end
  refuel(math.min(fuelNeeded, turtle.getFuelLevel() + 100))
  
  local slice = 0
  
  print("Starting tunnel dig...")
  if segment then
    print("Segment " .. segment .. " starting...")
  end
  
  while slice < length do
    slice = slice + 1
    
    -- Refuel check every 8 slices
    if slice % 8 == 0 then
      refuel(turtle.getFuelLevel() + 16)
    end
    
    -- Dig tunnel slice
    digTunnelSlice(height, width, autoPlace)
    
    -- Move forward for next slice
    gf()
    
    -- Block limit check
    if autoPlace then
      local currentResources = scanInventory()
      if currentResources.blocks <= 0 then
        print("Out of blocks!")
        break
      end
    end
    
    if slice >= 1000 then
      print("Safety stop at 1000 slices")
      break
    end
  end
  
  print("Done! Dug " .. slice .. " slices")
  if segment then
    print("Segment " .. segment .. " complete")
  end
end

-- Multi-turtle command
local function multiCommand()
  local function findModem()
    for _, side in pairs(rs.getSides()) do
      if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
        return side
      end
    end
    error("No modem found!")
  end
  
  rednet.open(findModem())
  
  print("Multi-Turtle eDig")
  write("Turtle IDs (space-separated): ")
  local idStr = read()
  local ids = {}
  for id in idStr:gmatch("%S+") do
    local num = tonumber(id)
    if num then table.insert(ids, num) end
  end
  
  if #ids == 0 then
    print("No valid turtle IDs")
    return
  end
  
  write("Tunnel height (blocks) [3]: ")
  local height = tonumber(read()) or 3
  
  write("Tunnel length (blocks) [32]: ")
  local length = tonumber(read()) or 32
  
  write("Tunnel width (blocks) [3]: ")
  local width = tonumber(read()) or 3
  
  write("Place floor blocks? (y/n) [n]: ")
  local place = string.lower(read()) == "y" and "place" or ""
  
  write("Segment mode? (y/n) [n]: ")
  local segmentMode = string.lower(read()) == "y"
  
  local segmentLength = 0
  if segmentMode then
    write("Segment length (blocks per turtle) [8]: ")
    segmentLength = tonumber(read()) or 8
  end
  
  -- Build command
  local cmd = tostring(height) .. " " .. tostring(length) .. " " .. tostring(width)
  if place ~= "" then cmd = cmd .. " " .. place end
  
  -- Send to turtles
  if segmentMode then
    print("Sending segmented jobs to " .. #ids .. " turtles")
    local totalLength = length
    local segments = math.ceil(totalLength / segmentLength)
    
    for i = 1, #ids do
      local turtleId = ids[i]
      local segmentStart = (i - 1) * segmentLength
      local segmentEnd = math.min(segmentStart + segmentLength, totalLength)
      local segmentLengthActual = segmentEnd - segmentStart
      
      if segmentLengthActual > 0 then
        local segmentCmd = cmd .. " " .. tostring(i)
        print("Sending to turtle " .. turtleId .. ": dig " .. segmentCmd .. " (segment " .. i .. ", length " .. segmentLengthActual .. ")")
        rednet.send(turtleId, {command = "RUN", args = segmentCmd})
      end
    end
  else
    print("Sending to " .. #ids .. " turtles: dig " .. cmd)
    for _, id in ipairs(ids) do
      rednet.send(id, {command = "RUN", args = cmd})
      print("Sent to turtle " .. id)
    end
  end
  
  print("Jobs sent!")
end

-- Client command
local function clientCommand()
  local function findModem()
    for _, side in pairs(rs.getSides()) do
      if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
        return side
      end
    end
    error("No modem found!")
  end
  
  rednet.open(findModem())
  local id = os.getComputerID()
  
  print("eDig client ready (ID: " .. id .. ")")
  print("Waiting for jobs...")
  
  while true do
    local sender, msg, protocol = rednet.receive()
    
    local cmd = ""
    if type(msg) == "table" and msg.command == "RUN" then
      cmd = msg.args or ""
    elseif type(msg) == "string" then
      cmd = msg
    end
    
    if cmd ~= "" then
      print("Running: " .. cmd)
      local ok, err = pcall(function()
        shell.run("edig dig " .. cmd)
      end)
      
      if ok then
        rednet.send(sender, {status = "done", id = id})
        print("Job completed")
      else
        rednet.send(sender, {status = "error", id = id, error = err})
        print("Job failed: " .. tostring(err))
      end
    end
  end
end

-- Install command
local function installCommand()
  print("Installing eDig system...")
  
  local files = {
    "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/edig.lua"
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
  
  if downloadFile(files[1], "edig") then
    success = success + 1
  end
  
  print("Installed " .. success .. " files")
  
  if turtle then
    print("Turtle setup complete!")
    print("Run 'edig client' to start listening for jobs")
    print("Or run 'edig dig <height> <length> <width> [place] [segment]' directly")
  else
    print("Computer setup complete!")
    print("Run 'edig multi' to send jobs to turtles")
  end
end

-- Help command
local function helpCommand()
  print("eDig All-in-One System")
  print("Usage: edig [command] [args...]")
  print()
  print("Commands:")
  print("  dig [height] [length] [width] [place] [segment]")
  print("    - Dig a straight tunnel")
  print("    - Interactive mode if no args provided")
  print()
  print("  multi")
  print("    - Send jobs to multiple turtles")
  print("    - Supports segmentation mode")
  print()
  print("  client")
  print("    - Start remote listener for jobs")
  print("    - Use on turtle clients")
  print()
  print("  install")
  print("    - Download and install the system")
  print("    - Sets up all necessary files")
  print()
  print("  help")
  print("    - Show this help message")
  print()
  print("Examples:")
  print("  edig dig 3 32 3          -- 3x3x32 tunnel")
  print("  edig dig 4 50 5 place    -- 4x5x50 tunnel with floors")
  print("  edig multi               -- Multi-turtle coordinator")
  print("  edig client              -- Start turtle client")
  print("  edig install             -- Install system")
end

-- Main command router
local command = args[1] or "help"

if command == "dig" then
  digCommand()
elseif command == "multi" then
  multiCommand()
elseif command == "client" then
  clientCommand()
elseif command == "install" then
  installCommand()
elseif command == "help" then
  helpCommand()
else
  print("Unknown command: " .. command)
  print("Use 'edig help' for available commands")
end
