-- stairs.lua - Fast stair builder
-- Usage: stairs [height] [up/down] [steps] [place]

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

-- Smart block placement - use any non-fuel items
local function findBlockSlot()
  for i = 1, 16 do
    local count = turtle.getItemCount(i)
    if count > 0 then
      turtle.select(i)
      -- Test if it's fuel by trying to refuel 0 items
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
local height = 3
local goUp = true
local steps = nil
local autoPlace = false
local surface = true

if #args >= 1 then
  height = math.max(1, tonumber(args[1]) or 3)
  for i = 2, #args do
    local arg = string.lower(args[i])
    local num = tonumber(args[i])
    if num then
      steps = math.max(1, num)
      surface = false
    elseif arg == "down" then
      goUp = false
      surface = false
    elseif arg == "up" then
      goUp = true
    elseif arg == "place" then
      autoPlace = true
    end
  end
else
  -- Simple prompts
  term.clear()
  term.setCursorPos(1, 1)
  print("Stair Builder")
  write("Height [3]: ")
  local h = read()
  if h ~= "" then height = math.max(1, tonumber(h) or 3) end
  
  write("Direction (u/d) [u]: ")
  local dir = string.lower(read())
  if dir == "d" or dir == "down" then
    goUp = false
    surface = false
  end
  
  if goUp then
    write("To surface? (y/n) [y]: ")
    local surf = string.lower(read())
    surface = not (surf == "n" or surf == "no")
  end
  
  if not surface then
    write("Steps [32]: ")
    local s = read()
    steps = math.max(1, tonumber(s) or 32)
  end
  
  write("Place blocks? (y/n) [n]: ")
  local place = string.lower(read())
  autoPlace = (place == "y" or place == "yes")
end

-- Main loop
print("Building " .. (goUp and "up" or "down") .. " stairs, height=" .. height)
if surface then
  print("Mode: to surface")
else
  print("Steps: " .. steps)
end

-- Initial fuel check
local fuelNeeded = (steps or 64) * 3
refuel(math.min(fuelNeeded, 200))

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
    clearUp(height)
  else
    df(); gf(); dd(); gd()
    if autoPlace then placeFloor() end
    clearDown(height)
  end
  
  -- Exit conditions
  if not surface and step >= (steps or 32) then
    break
  end
  
  if surface and goUp then
    if not turtle.detect() and not turtle.detectUp() then
      openStreak = openStreak + 1
    else
      openStreak = 0
    end
    if openStreak >= 5 then break end
  end
  
  if step >= 1000 then
    print("Safety stop at 1000 steps")
    break
  end
end

print("Done! Built " .. step .. " steps")
