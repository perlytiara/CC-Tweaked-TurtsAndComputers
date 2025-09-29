-- stairs.lua - Fast stair builder  
-- Usage: stairs [headroom] [up/down] [length] [place]
-- headroom = blocks above each step, length = total steps to build

local args = {...}

local function hasTurtle()
  return pcall(function() return turtle.getFuelLevel() end)
end

if not hasTurtle() then
  print("Turtle required!")
  return
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

-- Resource scanning and management
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

local function placeFloor()
  if not turtle.detectDown() then
    local slot = findBlockSlot()
    if slot then
      turtle.select(slot)
      turtle.placeDown()
    end
  end
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

-- Clear headroom
local function clearUp(h)
  du(); gu()
  for i = 1, h - 1 do
    du()
    if i < h - 1 then gu() end
  end
  for i = 1, math.max(h - 2, 0) do gd() end
end

local function clearDown(h)
  for i = 1, h - 1 do gu() end
  du()
  for i = 1, h - 1 do gd() end
end

-- Parse arguments
local headroom = 3  -- blocks above each step
local goUp = true
local length = nil  -- number of steps to build
local autoPlace = false
local autoLength = false  -- use surface detection for up, or blocks available

if #args >= 1 then
  headroom = math.max(1, tonumber(args[1]) or 3)
  for i = 2, #args do
    local arg = string.lower(args[i])
    local num = tonumber(args[i])
    if num then
      length = math.max(1, num)
      autoLength = false
    elseif arg == "down" then
      goUp = false
    elseif arg == "up" then
      goUp = true
    elseif arg == "place" then
      autoPlace = true
    elseif arg == "auto" then
      autoLength = true
    end
  end
else
  -- Interactive prompts
  term.clear()
  term.setCursorPos(1, 1)
  print("Stair Builder")
  
  -- Scan resources first
  local resources = scanInventory()
  print("Resources: " .. resources.fuel .. " fuel, " .. resources.blocks .. " blocks")
  
  write("Headroom (blocks above steps) [3]: ")
  local h = read()
  if h ~= "" then headroom = math.max(1, tonumber(h) or 3) end
  
  write("Direction (u/d) [u]: ")
  local dir = string.lower(read())
  goUp = not (dir == "d" or dir == "down")
  
  -- Length options
  local maxSteps = math.floor(resources.blocks / (autoPlace and 1 or 0.1)) -- rough estimate
  if goUp then
    write("Length - steps/surface/auto [surface]: ")
    local lengthInput = string.lower(read())
    if lengthInput == "surface" or lengthInput == "" then
      autoLength = true
      length = nil
    elseif lengthInput == "auto" then
      autoLength = true
      length = maxSteps
    else
      local num = tonumber(lengthInput)
      if num then
        length = math.max(1, num)
        autoLength = false
      else
        autoLength = true
      end
    end
  else
    write("Depth (steps down) [32]: ")
    local s = read()
    length = math.max(1, tonumber(s) or 32)
    autoLength = false
  end
  
  write("Place floor blocks? (y/n) [n]: ")
  local place = string.lower(read())
  autoPlace = (place == "y" or place == "yes")
end

-- Set defaults if not specified
if not length and not autoLength then
  if goUp then
    autoLength = true  -- surface detection for up
  else
    length = 32  -- default depth for down
  end
end

-- Resource check and planning
local resources = scanInventory()
print("Building " .. (goUp and "up" or "down") .. " stairs")
print("Headroom: " .. headroom .. " blocks above each step")

if autoLength and goUp then
  print("Mode: to surface (auto-detect)")
elseif autoLength then
  print("Length: auto (max " .. math.floor(resources.blocks / (autoPlace and 1 or 0.1)) .. " steps)")
else
  print("Length: " .. (length or "unknown") .. " steps")
end

print("Resources: " .. resources.fuel .. " fuel, " .. resources.blocks .. " blocks")

-- Estimate what we can build
local blocksPerStep = autoPlace and 1 or 0
local maxPossibleSteps = blocksPerStep > 0 and math.floor(resources.blocks / blocksPerStep) or 999
if autoPlace and maxPossibleSteps < (length or 32) then
  print("Warning: Only enough blocks for " .. maxPossibleSteps .. " steps with floor placement")
end

-- Initial fuel check
local fuelNeeded = (length or 64) * 3
if resources.fuel * 80 < fuelNeeded then  -- rough fuel value estimate
  print("Warning: May need more fuel")
end
refuel(math.min(fuelNeeded, turtle.getFuelLevel() + 100))

local step = 0
local openStreak = 0

while true do
  step = step + 1
  
  -- Refuel check every 8 steps
  if step % 8 == 0 then
    refuel(turtle.getFuelLevel() + 16)
  end
  
  -- Build step
  if goUp then
    df(); gf()
    if autoPlace then placeFloor() end
    clearUp(headroom)
  else
    df(); gf(); dd(); gd()
    if autoPlace then placeFloor() end
    clearDown(headroom)
  end
  
  -- Exit conditions
  if not autoLength and step >= (length or 32) then
    break
  end
  
  -- Surface detection for up stairs
  if autoLength and goUp then
    if not turtle.detect() and not turtle.detectUp() then
      openStreak = openStreak + 1
    else
      openStreak = 0
    end
    if openStreak >= 5 then break end
  end
  
  -- Block limit check
  if autoPlace then
    local currentResources = scanInventory()
    if currentResources.blocks <= 0 then
      print("Out of blocks!")
      break
    end
  end
  
  if step >= 1000 then
    print("Safety stop at 1000 steps")
    break
  end
end

print("Done! Built " .. step .. " steps")