-- Master script to launch multiple turtles with divided params

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

-- For two turtles; extend for more
print("Enter number of turtles (supports 2):")
local num = tonumber(read())
if num ~= 2 then
  print("Defaulting to 2 turtles.")
  num = 2
end

print("Enter LEFT-corner turtle ID (use os.getComputerID() on turtle):")
local id1 = tonumber(read())
print("Enter RIGHT-corner turtle ID:")
local id2 = tonumber(read())

print("Enter total depth (positive):")
local depth = tonumber(read())
print("Enter total width (positive):")
local totalWidth = tonumber(read())
print("Enter height:")
local height = tonumber(read())
print("Enter options (space-separated, e.g. layerbylayer startwithin):")
local options = read()

-- Divide width (handle odd by giving extra to one side)
local half1 = math.floor(totalWidth / 2)
local half2 = totalWidth - half1

-- Params strings
local params1 = tostring(depth) .. " " .. tostring(half1) .. " " .. tostring(height) .. " " .. (options or "")
local params2 = tostring(depth) .. " " .. tostring(-half2) .. " " .. tostring(height) .. " " .. (options or "")

-- Also send a structured payload some listeners can parse directly
local masterId = os.getComputerID()
local payload1 = { command = "RUN", program = "tClear", args = params1, masterId = masterId, role = "left" }
local payload2 = { command = "RUN", program = "tClear", args = params2, masterId = masterId, role = "right" }

print("Sending to left turtle (ID " .. id1 .. "): " .. params1)
rednet.send(id1, payload1, "tclear-run")
rednet.send(id1, params1, "tclear-run") -- fallback for simple listeners
print("Sending to right turtle (ID " .. id2 .. "): " .. params2)
rednet.send(id2, payload2, "tclear-run")
rednet.send(id2, params2, "tclear-run") -- fallback for simple listeners

print("Turtles should start digging now.")