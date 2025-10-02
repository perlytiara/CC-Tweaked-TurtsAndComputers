-- multi.lua - Send coordinated eDig jobs to multiple turtles
local function findModem()
  for _, side in pairs(rs.getSides()) do
    if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
      return side
    end
  end
  error("No modem found!")
end

rednet.open(findModem())

print("Multi-Turtle eDig Coordinator")
print("Supports simultaneous row-based coordination")

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
  if shape == "size2" then
    height = 3
    width = 7
    print("Dome shape: size2 (7 wide, max 7 turtles)")
  else
    height = 3
    width = 5
    print("Dome shape: custom (5 wide, max 5 turtles)")
  end
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
local maxTurtles = shape == "straight" and width or (shape == "size2" and 7 or 5)
if #ids > maxTurtles then
  print("Warning: " .. shape .. " shape supports max " .. maxTurtles .. " turtles")
  print("Using first " .. maxTurtles .. " turtles")
  while #ids > maxTurtles do
    table.remove(ids)
  end
end

write("Coordination mode:")
print("1. Row-based (turtles work on different rows simultaneously)")
print("2. Segment-based (turtles work on different segments)")
write("Choose (1/2) [1]: ")
local coordMode = read()
if coordMode ~= "2" then coordMode = "1" end

local segmentLength = 0
if coordMode == "2" then
  write("Segment length (blocks per turtle) [8]: ")
  segmentLength = tonumber(read()) or 8
end

-- Build command
local cmd = tostring(height) .. " " .. tostring(length) .. " " .. tostring(width)
if place ~= "" then cmd = cmd .. " " .. place end
if shape ~= "straight" then cmd = cmd .. " " .. shape end

-- Send to turtles with coordination
print("\nSending coordinated jobs to " .. #ids .. " turtles...")

if coordMode == "2" then
  -- Segment-based coordination
  print("Segment-based coordination")
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
  -- Row-based coordination (simultaneous)
  print("Row-based coordination - all turtles start simultaneously")
  for i = 1, #ids do
    local turtleId = ids[i]
    local rowCmd = cmd .. " " .. tostring(i) .. " " .. tostring(width)
    print("Turtle " .. turtleId .. " (Row " .. i .. "): " .. width .. " blocks wide")
    rednet.send(turtleId, {command = "RUN", args = rowCmd})
  end
end

print("\nJobs sent! All turtles starting simultaneously...")
print("Monitor individual turtle progress for coordination status.")