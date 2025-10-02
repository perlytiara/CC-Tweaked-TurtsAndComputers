-- client.lua - Remote eDig listener
local function findModem()
  for _, side in pairs(rs.getSides()) do
    if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
      return side
    end
  end
  error("No modem found!")
end

rednet.open(findModem())
local id = os.getComputerID()

print("eDig client ready (ID: " .. id .. ")")
print("Waiting for jobs...")

while true do
  local sender, msg, protocol = rednet.receive()
  
  local cmd = ""
  if type(msg) == "table" and msg.command == "RUN" then
    cmd = msg.args or ""
  elseif type(msg) == "string" then
    cmd = msg
  end
  
  if cmd ~= "" then
      print("Running: eDig/edig dig " .. cmd)
      local ok, err = pcall(function()
        -- Try different paths to find the edig program
        if fs.exists("eDig/edig") then
          shell.run("eDig/edig dig " .. cmd)
        elseif fs.exists("edig") then
          shell.run("edig dig " .. cmd)
        else
          error("Could not find edig program")
        end
      end)
    
    if ok then
      rednet.send(sender, {status = "done", id = id})
      print("Job completed")
    else
      rednet.send(sender, {status = "error", id = id, error = err})
      print("Job failed: " .. tostring(err))
    end
  end
end
