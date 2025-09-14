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

-- Ask for chunky turtle IDs
print("Enter LEFT chunky turtle ID (or press Enter to skip):")
local chunkyInput1 = read()
local chunkyId1 = nil
if chunkyInput1 ~= "" then
  chunkyId1 = tonumber(chunkyInput1)
end

print("Enter RIGHT chunky turtle ID (or press Enter to skip):")
local chunkyInput2 = read()
local chunkyId2 = nil
if chunkyInput2 ~= "" then
  chunkyId2 = tonumber(chunkyInput2)
end

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

-- Start chunky turtles first if available
if chunkyId1 then
  print("Starting left chunky turtle (ID " .. chunkyId1 .. ")...")
  local chunkyPayload1 = { command = "RUN", program = "tClearChunky", masterId = os.getComputerID(), role = "left_chunky" }
  rednet.send(chunkyId1, chunkyPayload1, "tclear-run")
  rednet.send(chunkyId1, chunkyPayload1, "tclear-chunky")
  sleep(1) -- Give chunky turtle time to start
end

if chunkyId2 then
  print("Starting right chunky turtle (ID " .. chunkyId2 .. ")...")
  local chunkyPayload2 = { command = "RUN", program = "tClearChunky", masterId = os.getComputerID(), role = "right_chunky" }
  rednet.send(chunkyId2, chunkyPayload2, "tclear-run")
  rednet.send(chunkyId2, chunkyPayload2, "tclear-chunky")
  sleep(1) -- Give chunky turtle time to start
end

-- Start main mining turtles
print("Sending to left turtle (ID " .. id1 .. "): " .. params1)
rednet.send(id1, payload1, "tclear-run")
rednet.send(id1, params1, "tclear-run") -- fallback for simple listeners
print("Sending to right turtle (ID " .. id2 .. "): " .. params2)
rednet.send(id2, payload2, "tclear-run")
rednet.send(id2, params2, "tclear-run") -- fallback for simple listeners

print("Turtles should start digging now.")
if chunkyId1 or chunkyId2 then
  print("Chunky turtles are paired and following to keep chunks loaded.")
end