-- multi.lua - Send stairs jobs to multiple turtles
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
print("Multi-Turtle Stairs")
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

write("Headroom (blocks above steps) [3]: ")
local headroom = tonumber(read()) or 3

write("Direction (u/d) [u]: ")
local dir = string.lower(read())
if dir == "d" then dir = "down" else dir = "up" end

local length = ""
if dir == "down" then
  write("Depth (steps down) [32]: ")
  length = tostring(tonumber(read()) or 32)
else
  write("Length - steps/surface/auto [surface]: ")
  local lengthInput = string.lower(read())
  if lengthInput ~= "" and lengthInput ~= "surface" then
    if lengthInput == "auto" then
      length = "auto"
    else
      local num = tonumber(lengthInput)
      if num then
        length = tostring(num)
      end
    end
  end
end

write("Place floor blocks? (y/n) [n]: ")
local place = string.lower(read()) == "y" and "place" or ""

-- Build command
local cmd = tostring(headroom) .. " " .. dir
if length ~= "" then cmd = cmd .. " " .. length end
if place ~= "" then cmd = cmd .. " " .. place end

-- Send to turtles
print("Sending to " .. #ids .. " turtles: stairs " .. cmd)
for _, id in ipairs(ids) do
  rednet.send(id, {command = "RUN", args = cmd})
  print("Sent to turtle " .. id)
end

print("Jobs sent!")
