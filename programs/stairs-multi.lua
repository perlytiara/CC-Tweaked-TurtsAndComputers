-- stairs-multi.lua - Send stairs jobs to multiple turtles
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

write("Height [3]: ")
local height = tonumber(read()) or 3

write("Direction (u/d) [u]: ")
local dir = string.lower(read())
if dir == "d" then dir = "down" else dir = "up" end

local steps = ""
if dir == "down" then
  write("Steps [32]: ")
  steps = tostring(tonumber(read()) or 32)
end

write("Place blocks? (y/n) [n]: ")
local place = string.lower(read()) == "y" and "place" or ""

-- Build command
local cmd = tostring(height) .. " " .. dir
if steps ~= "" then cmd = cmd .. " " .. steps end
if place ~= "" then cmd = cmd .. " " .. place end

-- Send to turtles
print("Sending to " .. #ids .. " turtles: stairs " .. cmd)
for _, id in ipairs(ids) do
  rednet.send(id, {command = "RUN", args = cmd})
  print("Sent to turtle " .. id)
end

print("Jobs sent!")
