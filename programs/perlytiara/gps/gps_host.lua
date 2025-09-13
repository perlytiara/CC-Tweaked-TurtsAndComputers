-- startup
local x, y, z = 100, 64, -200  -- set to this computer's coords
shell.run(("gps host %d %d %d"):format(x, y, z))