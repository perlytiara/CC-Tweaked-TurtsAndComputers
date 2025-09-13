-- startup
local m = peripheral.find("modem", function(_, mm) return mm.isWireless and mm.isWireless() end)
if not m then error("Attach wireless modem") end
m.open(0) -- client port
m.transmit(420, 0, "CLIENT_DEPLOYED") -- ping server
-- fetch and run client
local url = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/BigBaemingGamers/client/client.lua"
local r = http.get(url); local code = r.readAll(); r.close()
local f = fs.open("client.lua","w"); f.write(code); f.close()
shell.run("client.lua")