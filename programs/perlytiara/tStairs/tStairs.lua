-- tStairs.lua
-- Fast staircase builder for ComputerCraft turtles.
--
-- Features
-- - Builds stairs UP (default) or DOWN
-- - Clears exactly the requested headroom ABOVE each tread
-- - "Surface" mode (UP only) stops when sustained open air is detected
-- - Minimal checks per step for speed; refuels periodically
--
-- Arguments (order flexible after headroom):
--   tStairs <headroom> [up|down] [surface] [<steps>] [place]
-- Examples:
--   tStairs 3                -> headroom=3, up, surface mode
--   tStairs 5 up 80          -> headroom=5, up, 80 steps
--   tStairs 2 down 40        -> headroom=2, down, 40 steps
--   tStairs 4 up place       -> headroom=4, up, surface, place floors if missing

---------------------------------------
-- helpers -----------------------------
---------------------------------------
local tArgs = {...}

local function hasTurtle()
  return pcall(function() return turtle.getFuelLevel() end)
end

local function df()  while turtle.detect()   do turtle.dig()   end end
local function du()  while turtle.detectUp() do turtle.digUp() end end
local function dd()  while turtle.detectDown() do turtle.digDown() end end
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

local function findAnyPlaceableSlot(startAt)
  local first = startAt or 1
  for i = first, 16 do
    if turtle.getItemCount(i) > 0 then return i end
  end
  for i = 1, (first - 1) do
    if turtle.getItemCount(i) > 0 then return i end
  end
  return nil
end

local function ensureFloorIfRequested(placeFloor)
  if not placeFloor then return end
  if not turtle.detectDown() then
    local slot = findAnyPlaceableSlot(1)
    if slot ~= nil then
      local current = turtle.getSelectedSlot()
      turtle.select(slot)
      turtle.placeDown()
      turtle.select(current)
    end
  end
end

-- robust fuel management: scan all slots and optionally wait for user to provide fuel
local function ensureFuel(minFuelTarget, waitForItems)
  if turtle.getFuelLevel() == "unlimited" then return true end

  local function consumeIncremental()
    local before = turtle.getFuelLevel()
    local cur = turtle.getSelectedSlot()
    for i = 1, 16 do
      local count = turtle.getItemCount(i)
      if count > 0 then
        turtle.select(i)
        while count > 0 and turtle.getFuelLevel() < minFuelTarget do
          turtle.refuel(1)
          count = count - 1
        end
        if turtle.getFuelLevel() >= minFuelTarget then break end
      end
    end
    turtle.select(cur)
    return turtle.getFuelLevel() > before
  end

  while turtle.getFuelLevel() < minFuelTarget do
    if consumeIncremental() then
      -- consumed some fuel items; loop continues until target reached
    else
      if not waitForItems then return false end
      print("Need fuel (" .. turtle.getFuelLevel() .. "/" .. minFuelTarget .. "). Put coal/charcoal in any slot.")
      local dots = 0
      while turtle.getFuelLevel() < minFuelTarget do
        sleep(1)
        term.write(".")
        dots = dots + 1
        if consumeIncremental() then break end
        if dots % 30 == 0 then print() end
      end
      print()
    end
  end
  return true
end

local function clearHeadroomUp(h)
  du()
  gu()
  for i = 1, h - 1 do
    du()
    if i < h - 1 then gu() end
  end
  for i = 1, math.max(h - 2, 0) do gd() end
end

local function clearHeadroomDown(h)
  for i = 1, h - 1 do gu() end
  du()
  for i = 1, h - 1 do gd() end
end

---------------------------------------
-- params ------------------------------
---------------------------------------
if not hasTurtle() then
  print("This program must run on a turtle.")
  return
end

local maxSteps = nil           -- number of steps (vertical rise)
local placeFloor = false
local HEADROOM = nil           -- blocks above each step to clear
local runToSurface = true      -- default behavior
local directionUp = true       -- true: build up, false: build down

local function askNumber(prompt, minV, maxV, defaultV)
  while true do
    if defaultV then
      write(prompt .. " [" .. defaultV .. "]: ")
    else
      write(prompt .. ": ")
    end
    local s = read()
    if s == "" and defaultV then return defaultV end
    local n = tonumber(s)
    if n then
      n = math.floor(n)
      if minV and n < minV then n = minV end
      if maxV and n > maxV then n = maxV end
      return n
    end
  end
end

-- Prefer interactive prompts, but allow simple args fallback: tStairs <steps> <width> [place]
if #tArgs >= 1 then
  HEADROOM = math.max(1, math.floor(tonumber(tArgs[1]) or 2))
  for i = 2, #tArgs do
    local a = tArgs[i]
    local n = tonumber(a)
    if n ~= nil then
      maxSteps = math.max(1, math.floor(n))
      runToSurface = false
    else
      a = string.lower(a)
      if a == "place" then placeFloor = true end
      if a == "surface" then runToSurface = true end
      if a == "down" or a == "dir=down" then directionUp = false runToSurface = false end
      if a == "up" or a == "dir=up" then directionUp = true end
    end
  end
else
  term.clear() term.setCursorPos(1,1)
  print("Staircase builder (1-block steps)")
  HEADROOM = askNumber("Enter headroom height above each step (blocks)", 1, 10, 2)
  write("Direction (up/down) [up]: ")
  local dAns = string.lower(read())
  if dAns == "down" or dAns == "d" then directionUp = false runToSurface = false else directionUp = true end
  write("Run until surface? (Y/n): ")
  local ansSurf = string.lower(read())
  runToSurface = directionUp and (not (ansSurf == "n" or ansSurf == "no")) or false
  if not runToSurface then
    maxSteps = askNumber("Enter number of steps (vertical rise)", 1, 4096, 32)
  end
  write("Place floor blocks if missing? (y/N): ")
  local ans = string.lower(read())
  placeFloor = (ans == "y" or ans == "yes")
end

-- heuristic: consider we reached surface when we see open air above
-- and ahead for a few consecutive steps.
local openStreak = 0
local openNeeded = 6

---------------------------------------
-- main --------------------------------
---------------------------------------
print("tStairs: building staircase...")
local dirLabel = directionUp and "up" or "down"
if runToSurface then
  print("Headroom:", HEADROOM, " direction:", dirLabel, " mode:", "until surface", " floor:", placeFloor and "on" or "off")
else
  print("Headroom:", HEADROOM, " direction:", dirLabel, " steps:", maxSteps, " floor:", placeFloor and "on" or "off")
end

-- movement/fuel model per step (single-width): forward (1) + vertical (1)
local perStepFuel = 2
local estimatedNeeded
if runToSurface then
  -- start with a reasonable buffer (e.g., ~64 steps worth)
  estimatedNeeded = math.floor(perStepFuel * 64 * 1.1) + 10
else
  estimatedNeeded = math.floor(perStepFuel * maxSteps * 1.1) + 10
end
ensureFuel(math.min(estimatedNeeded, turtle.getFuelLevel() + 256), true)

-- Refuel cadence to avoid costly scans every step
local REFUEL_MODULO = 8
local stepSinceRefuel = 0

local openStreak, openNeeded = 0, 5
local step = 0
local maxSafetySteps = 8192
while true do
  step = step + 1
  -- fuel guard: maintain a modest buffer without draining entire stacks
  if turtle.getFuelLevel() ~= "unlimited" then
    stepSinceRefuel = stepSinceRefuel + 1
    if turtle.getFuelLevel() < 6 or (stepSinceRefuel % REFUEL_MODULO == 0) then
      local target = turtle.getFuelLevel() + perStepFuel * 8
      ensureFuel(target, false)
    end
  end

  -- carve one stair step (directional)
  if directionUp then
    df(); gf(); ensureFloorIfRequested(placeFloor)
    clearHeadroomUp(HEADROOM)
  else
    df(); gf(); dd(); gd(); ensureFloorIfRequested(placeFloor)
    clearHeadroomDown(HEADROOM)
  end

  -- skip sucking items for speed

  -- exit conditions
  if not runToSurface then
    if step >= (maxSteps or 0) then break end
  else
    if directionUp then
      local aheadBlocked = turtle.detect()
      local aboveBlocked = turtle.detectUp()
      if (not aheadBlocked) and (not aboveBlocked) then
        openStreak = openStreak + 1
      else
        openStreak = 0
      end
      if openStreak >= openNeeded then break end
    end
    if step >= maxSafetySteps then print("Safety stop: too many steps.") break end
  end
end

print("tStairs: done.")