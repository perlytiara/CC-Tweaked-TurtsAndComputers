-- startup on each deployable turtle
local modem = peripheral.find("modem", function(_, m) return m.isWireless and m.isWireless() end)
if not modem then error("Attach a wireless modem to turtle") end
modem.open(0) -- client port

local SERVER_PORT, CLIENT_PORT = 420, 0
-- Send handshake via modem_message API
peripheral.call(peripheral.getName(modem), "transmit", SERVER_PORT, CLIENT_PORT, "CLIENT_DEPLOYED")

-- Fetch and run client
local url = "https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/BigBaemingGamers/client/client.lua"
local r = http.get(url); local code = r.readAll(); r.close()
local f = fs.open("client.lua","w"); f.write(code); f.close()
shell.run("client.lua")