-- edig.lua - Advanced tunnel digger with dome shapes and multi-turtle coordination
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
      local success = turtle.placeDown()
      if not success then
        print("Warning: Could not place floor block (no blocks available)")
        return false
      end
      return true
    else
      print("Warning: No blocks available for floor placement")
      return false
    end
  end
  return true
end

-- Dome tunnel shapes
local DOME_SHAPES = {
  ["size2"] = {
    width = 7,
    heights = {3,3,4,4,4,3,3},
    maxTurtles = 7
  },
  ["custom"] = {
    width = 5,
    heights = {3,4,4,4,3},
    maxTurtles = 5
  }
}

-- Calculate dome shape heights
local function getDomeHeights(shape, width, sideHeight, centerHeight, radius)
  if shape == "size2" then
    return DOME_SHAPES.size2.heights
  elseif shape == "custom" then
    local heights = {}
    for x = 0, width - 1 do
      if radius <= 0 then
        if x == 0 or x == width - 1 then 
          heights[x+1] = sideHeight 
        else 
          heights[x+1] = centerHeight 
        end
      else
        local u = 1 - (math.abs(2*x - (width - 1)) / (width - 1))
        local exponent = 1 / (1 + radius)
        local u2 = u ^ exponent
        local f = (1 - math.cos(math.pi * u2)) / 2
        local h = math.floor(0.5 + (sideHeight + (centerHeight - sideHeight) * f))
        if h < sideHeight then h = sideHeight end
        if h > centerHeight then h = centerHeight end
        heights[x+1] = h
      end
    end
    return heights
  end
  return {3,3,3} -- default
end

-- Check if we have blocks for floor placement
local function checkBlocksForFloor(shouldPlaceFloor)
  if shouldPlaceFloor then
    local slot = findBlockSlot()
    if not slot then
      print("No blocks available for floor placement!")
      print("Options:")
      print("1. Add blocks to inventory and press Enter")
      print("2. Type 'skip' to continue without floor placement")
      print("3. Type 'stop' to abort")
      
      while true do
        write("Choice: ")
        local choice = string.lower(read())
        if choice == "skip" then
          return false
        elseif choice == "stop" then
          error("Operation aborted by user")
        elseif choice == "" then
          slot = findBlockSlot()
          if slot then
            print("Blocks found! Continuing...")
            return true
          else
            print("Still no blocks. Please add blocks or type 'skip' or 'stop'")
          end
        end
      end
    end
  end
  return shouldPlaceFloor
end

-- Straight tunnel digging
local function digStraightTunnel(height, width, length, shouldPlaceFloor)
  local slice = 0
  
  print("Starting straight tunnel dig...")
  print("Dimensions: " .. length .. "x" .. width .. "x" .. height)
  
  while slice < length do
    slice = slice + 1
    
    -- Refuel check every 8 slices
    if slice % 8 == 0 then
      refuel(turtle.getFuelLevel() + 16)
    end
    
    -- Dig tunnel slice
    digTunnelSlice(height, width, shouldPlaceFloor)
    
    -- Move forward for next slice
    gf()
    
    if slice >= 1000 then
      print("Safety stop at 1000 slices")
      break
    end
  end
  
  print("Done! Dug " .. slice .. " slices")
end

-- Dig dome slice
local function digDomeSlice(heights, width, shouldPlaceFloor)
  shouldPlaceFloor = checkBlocksForFloor(shouldPlaceFloor)
  
  -- Enter slice
  df()
  gf()
  
  -- Move to level 2 for dome shape
  if heights[1] >= 2 then
    gu()
  end
  
  -- Dig left to right
  for x = 1, width do
    local h = heights[x] or 0
    
    -- Adjust height
    if h >= 1 then turtle.digDown() end
    if h >= 3 then du() end
    
    -- Move right if not last column
    if x < width then
      turtle.turnLeft()
      df()
      gf()
      turtle.turnRight()
    end
  end
  
  -- Upper pass for height 4 columns
  local needUpper = false
  for i = 1, #heights do
    if heights[i] >= 4 then needUpper = true break end
  end
  
  if needUpper then
    gu() -- Move to level 3
    for x = 1, width do
      if (heights[x] or 0) >= 4 then du() end
      if x < width then
        turtle.turnLeft()
        gf()
        turtle.turnRight()
      end
    end
    gd() -- Return to level 2
  end
  
  -- Return to base level
  gd()
  
  -- Return to starting position
  for w = 1, width - 1 do
    turtle.turnLeft()
    gf()
    turtle.turnRight()
  end
end

-- Dome tunnel digging
local function digDomeTunnel(shape, length, shouldPlaceFloor)
  local heights = getDomeHeights(shape, DOME_SHAPES[shape].width, 3, 4, 0)
  local width = DOME_SHAPES[shape].width
  local slice = 0
  
  print("Starting dome tunnel dig...")
  print("Shape: " .. shape .. " (" .. width .. " wide)")
  print("Length: " .. length)
  
  while slice < length do
    slice = slice + 1
    
    -- Refuel check every 8 slices
    if slice % 8 == 0 then
      refuel(turtle.getFuelLevel() + 16)
    end
    
    -- Dig dome slice
    digDomeSlice(heights, width, shouldPlaceFloor)
    
    -- Move forward for next slice
    gf()
    
    if slice >= 1000 then
      print("Safety stop at 1000 slices")
      break
    end
  end
  
  print("Done! Dug " .. slice .. " dome slices")
end

-- Dig tunnel slice (straight)
local function digTunnelSlice(height, width, shouldPlaceFloor)
  shouldPlaceFloor = checkBlocksForFloor(shouldPlaceFloor)
  
  -- Dig the slice in front of turtle
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
  local shape = "straight"
  
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
      elseif arg == "dome" or arg == "size2" then
        shape = "size2"
      elseif arg == "custom" then
        shape = "custom"
      end
    end
  else
    -- Interactive prompts
    term.clear()
    term.setCursorPos(1, 1)
    print("eDig - Advanced Tunnel Digger")
    
    local resources = scanInventory()
    print("Resources: " .. resources.fuel .. " fuel, " .. resources.blocks .. " blocks")
    
    write("Tunnel type (straight/dome/size2) [straight]: ")
    local t = string.lower(read())
    if t == "dome" or t == "size2" then
      shape = "size2"
    elseif t == "custom" then
      shape = "custom"
    end
    
    if shape == "straight" then
      write("Tunnel height (blocks) [3]: ")
      local h = read()
      if h ~= "" then height = math.max(1, tonumber(h) or 3) end
      
      write("Tunnel length (blocks) [32]: ")
      local l = read()
      if l ~= "" then length = math.max(1, tonumber(l) or 32) end
      
      write("Tunnel width (blocks) [3]: ")
      local w = read()
      if w ~= "" then width = math.max(1, tonumber(w) or 3) end
    else
      write("Tunnel length (blocks) [32]: ")
      local l = read()
      if l ~= "" then length = math.max(1, tonumber(l) or 32) end
    end
    
    write("Place floor blocks? (y/n) [n]: ")
    local place = string.lower(read())
    autoPlace = (place == "y" or place == "yes")
    
    write("Segment number (for multi-turtle) [none]: ")
    local seg = read()
    if seg ~= "" then segment = tonumber(seg) end
  end
  
  -- Resource check and planning
  local resources = scanInventory()
  print("Digging " .. shape .. " tunnel")
  
  if shape == "straight" then
    print("Dimensions: " .. length .. "x" .. width .. "x" .. height)
  else
    print("Shape: " .. shape .. " (" .. DOME_SHAPES[shape].width .. " wide)")
    print("Length: " .. length)
  end
  
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
  
  print("Starting tunnel dig...")
  if segment then
    print("Segment " .. segment .. " starting...")
  end
  
  -- Dig based on shape
  if shape == "straight" then
    digStraightTunnel(height, width, length, autoPlace)
  else
    digDomeTunnel(shape, length, autoPlace)
  end
  
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
  write("Tunnel type (straight/dome/size2) [straight]: ")
  local shape = string.lower(read())
  if shape ~= "dome" and shape ~= "size2" then
    shape = "straight"
  end
  
  local height, width, length
  if shape == "straight" then
    write("Tunnel height (blocks) [3]: ")
    height = tonumber(read()) or 3
    
    write("Tunnel width (blocks) [3]: ")
    width = tonumber(read()) or 3
  else
    height = DOME_SHAPES[shape].heights[1]
    width = DOME_SHAPES[shape].width
    print("Dome shape: " .. shape .. " (" .. width .. " wide, max " .. DOME_SHAPES[shape].maxTurtles .. " turtles)")
  end
  
  write("Tunnel length (blocks) [32]: ")
  length = tonumber(read()) or 32
  
  write("Place floor blocks? (y/n) [n]: ")
  local place = string.lower(read()) == "y" and "place" or ""
  
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
  
  -- Limit turtles based on shape
  local maxTurtles = shape == "straight" and width or DOME_SHAPES[shape].maxTurtles
  if #ids > maxTurtles then
    print("Warning: " .. shape .. " shape supports max " .. maxTurtles .. " turtles")
    print("Using first " .. maxTurtles .. " turtles")
    while #ids > maxTurtles do
      table.remove(ids)
    end
  end
  
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
  if shape ~= "straight" then cmd = cmd .. " " .. shape end
  
  -- Send to turtles with coordination
  print("Sending coordinated jobs to " .. #ids .. " turtles...")
  print("All turtles will start simultaneously")
  
  if segmentMode then
    local totalLength = length
    local segments = math.ceil(totalLength / segmentLength)
    
    for i = 1, #ids do
      local turtleId = ids[i]
      local segmentStart = (i - 1) * segmentLength
      local segmentEnd = math.min(segmentStart + segmentLength, totalLength)
      local segmentLengthActual = segmentEnd - segmentStart
      
      if segmentLengthActual > 0 then
        local segmentCmd = cmd .. " " .. tostring(i)
        print("Turtle " .. turtleId .. " (Segment " .. i .. "): " .. segmentLengthActual .. " blocks")
        rednet.send(turtleId, {command = "RUN", args = segmentCmd})
      end
    end
  else
    -- Simultaneous row-based coordination
    for i = 1, #ids do
      local turtleId = ids[i]
      local rowCmd = cmd .. " " .. tostring(i) .. " " .. tostring(width)
      print("Turtle " .. turtleId .. " (Row " .. i .. "): " .. width .. " blocks wide")
      rednet.send(turtleId, {command = "RUN", args = rowCmd})
    end
  end
  
  print("Jobs sent! All turtles starting simultaneously...")
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
      print("Running: edig dig " .. cmd)
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
  print("eDig Advanced Tunnel System")
  print("Usage: edig [command] [args...]")
  print()
  print("Commands:")
  print("  dig [height] [length] [width] [place] [segment] [shape]")
  print("    - Dig tunnels (straight or dome shapes)")
  print("    - Shapes: straight, dome, size2")
  print("    - Interactive mode if no args provided")
  print()
  print("  multi")
  print("    - Send coordinated jobs to multiple turtles")
  print("    - Supports simultaneous row-based coordination")
  print("    - Dome shapes: max 7 turtles (size2), max 5 turtles (custom)")
  print()
  print("  client")
  print("    - Start remote listener for jobs")
  print("    - Use on turtle clients")
  print()
  print("  install")
  print("    - Download and install the system")
  print()
  print("  help")
  print("    - Show this help message")
  print()
  print("Examples:")
  print("  edig dig 3 32 3              -- 3x3x32 straight tunnel")
  print("  edig dig 4 50 5 place       -- 4x5x50 tunnel with floors")
  print("  edig dig 0 100 0 dome       -- 7-wide dome tunnel (size2)")
  print("  edig multi                   -- Multi-turtle coordinator")
  print("  edig client                  -- Start turtle client")
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