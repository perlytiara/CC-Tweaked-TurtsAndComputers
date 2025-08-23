-- Master script to launch multiple turtles with same params for parallel stairs

-- Auto-detect a modem and open rednet
local function findModem()
  for _, p in pairs(rs.getSides()) do
    if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
      return p
    end
  end
  error("No modem attached to this computer.")
end

local modemSide = findModem()
rednet.open(modemSide)

local wrapped = peripheral.wrap(modemSide)
if wrapped and wrapped.isWireless and not wrapped.isWireless() then
  print("Note: Wired modem detected. Ensure turtles are cabled to the same network.")
end

-- Prompt for number of turtles and their IDs
print("Enter number of turtles:")
local num = tonumber(read()) or 1
local ids = {}
for i = 1, num do
  print("Enter turtle ID " .. i .. " (use os.getComputerID() on turtle):")
  local id = tonumber(read())
  if id then table.insert(ids, id) end
end

-- Prompt for tStairs parameters
print("Enter headroom:")
local headroom = tonumber(read()) or 3

print("Enter direction (up/down):")
local direction = read():lower()
if direction ~= "up" and direction ~= "down" then direction = "up" end

print("Run to surface? (y/n, only for up):")
local surfaceAns = read():lower()
local surface = (direction == "up" and surfaceAns == "y") and "surface" or ""

local steps = ""
if surface == "" then
  print("Enter number of steps:")
  steps = tostring(tonumber(read()) or 32)
end

print("Place floor if missing? (y/n):")
local placeAns = read():lower()
local place = (placeAns == "y") and "place" or ""

-- Construct args string
local args = tostring(headroom) .. " " .. direction
if surface ~= "" then args = args .. " " .. surface end
if steps ~= "" then args = args .. " " .. steps end
if place ~= "" then args = args .. " " .. place end
args = args:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

-- Send to each turtle
local masterId = os.getComputerID()
for i, id in ipairs(ids) do
  local payload = { command = "RUN", program = "tStairs", args = args, masterId = masterId, role = "row" .. i }
  print("Sending to turtle (ID " .. id .. "): tStairs " .. args)
  rednet.send(id, payload, "tstairs-run")
  rednet.send(id, args, "tstairs-run") -- fallback for simple listeners
end

print("Turtles should start building stairs now.")




