-- multi.lua - Send eDig jobs to multiple turtles
local function findModem()
  for _, side in pairs(rs.getSides()) do
    if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
      return side
    end
  end
  error("No modem found!")
end

rednet.open(findModem())

-- Simple prompts
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