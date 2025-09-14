--{program="tClearChunky",version="1.0",date="2024-10-22"}
---------------------------------------
-- tClearChunky           by Kaikaku
-- 2024-10-22, v1.0      chunky wireless turtle
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Chunky wireless turtle that pairs with a main mining turtle
-- to keep chunks loaded and prevent the main turtle from breaking
-- due to chunk unloading. Follows the main turtle's movements.

---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Requires a wireless modem for communication
-- Should be placed one block to the right of the main turtle

---------------------------------------
---- VARIABLES: template -------------- 
---------------------------------------
local cVersion  ="v1.0"             
local cPrgName  ="tClearChunky"          
local blnDebugPrint = false

---------------------------------------
---- VARIABLES: specific -------------- 
---------------------------------------
local masterTurtleId = nil
local chunkLoadingInterval = 2 -- seconds between chunk loading signals
local position = {x = 0, y = 0, z = 0, facing = 0} -- relative to master
local isActive = false

---------------------------------------
---- Communication functions -----------
---------------------------------------
local function findModem()
	for _, p in pairs(rs.getSides()) do
		if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
			return p
		end
	end
	error("No wireless modem attached to this turtle.")
end

local function sendChunkLoad()
	if masterTurtleId then
		rednet.send(masterTurtleId, {
			type = "chunk_load",
			id = os.getComputerID(),
			position = position,
			timestamp = os.time()
		}, "tclear-chunky")
	end
end

local function sendStatus(status, data)
	if masterTurtleId then
		rednet.send(masterTurtleId, {
			type = "status",
			status = status,
			id = os.getComputerID(),
			data = data or {},
			timestamp = os.time()
		}, "tclear-chunky")
	end
end

---------------------------------------
---- Movement functions ---------------
---------------------------------------
local function moveTo(x, y, z, facing)
	-- Calculate relative movement needed
	local dx = x - position.x
	local dy = y - position.y
	local dz = z - position.z
	local dfacing = (facing - position.facing) % 4
	
	-- Turn to correct facing first
	if dfacing == 1 then
		turtle.turnRight()
	elseif dfacing == 2 then
		turtle.turnRight()
		turtle.turnRight()
	elseif dfacing == 3 then
		turtle.turnLeft()
	end
	
	-- Move vertically first
	while dy > 0 do
		if turtle.up() then
			dy = dy - 1
			position.y = position.y + 1
		else
			break
		end
	end
	while dy < 0 do
		if turtle.down() then
			dy = dy + 1
			position.y = position.y - 1
		else
			break
		end
	end
	
	-- Move horizontally
	while dx > 0 do
		if turtle.forward() then
			dx = dx - 1
			position.x = position.x + 1
		else
			break
		end
	end
	while dx < 0 do
		turtle.turnLeft()
		turtle.turnLeft()
		if turtle.forward() then
			dx = dx + 1
			position.x = position.x - 1
		else
			break
		end
		turtle.turnLeft()
		turtle.turnLeft()
	end
	
	while dz > 0 do
		turtle.turnRight()
		if turtle.forward() then
			dz = dz - 1
			position.z = position.z + 1
		else
			break
		end
		turtle.turnLeft()
	end
	while dz < 0 do
		turtle.turnLeft()
		if turtle.forward() then
			dz = dz + 1
			position.z = position.z - 1
		else
			break
		end
		turtle.turnRight()
	end
	
	position.facing = facing
end

---------------------------------------
---- Main functions --------------------
---------------------------------------
local function debugPrint(str)
	if blnDebugPrint then
		print("[Chunky] " .. str)
	end
end

local function processMessage(message)
	if message.type == "pair" then
		masterTurtleId = message.masterId
		isActive = true
		debugPrint("Paired with master turtle " .. masterTurtleId)
		sendStatus("paired", {chunkyId = os.getComputerID()})
		return true
		
	elseif message.type == "move" then
		if isActive and message.target then
			debugPrint("Moving to " .. message.target.x .. "," .. message.target.y .. "," .. message.target.z)
			moveTo(message.target.x, message.target.y, message.target.z, message.target.facing or 0)
			sendStatus("moved", {position = position})
			return true
		end
		
	elseif message.type == "stop" then
		isActive = false
		debugPrint("Stopped by master turtle")
		sendStatus("stopped", {})
		return true
		
	elseif message.type == "ping" then
		sendStatus("alive", {position = position})
		return true
	end
	
	return false
end

---------------------------------------
---- Main program ----------------------
---------------------------------------

-- Initialize
local modemSide = findModem()
rednet.open(modemSide)

local thisId = os.getComputerID()
print("tClearChunky v" .. cVersion .. " starting...")
print("Chunky turtle ID: " .. thisId)
print("Waiting for pairing with master turtle...")

-- Send initial broadcast to find master
rednet.broadcast({
	type = "chunky_available",
	id = thisId,
	timestamp = os.time()
}, "tclear-chunky")

-- Main loop
local lastChunkLoad = 0

while true do
	local timer = os.startTimer(0.1) -- Check for messages every 0.1 seconds
	
	-- Handle rednet messages
	local senderId, message, protocol = rednet.receive(0.1)
	if senderId and (protocol == "tclear-chunky" or protocol == nil) then
		processMessage(message)
	end
	
	-- Send chunk loading signal periodically
	local currentTime = os.time()
	if isActive and (currentTime - lastChunkLoad) >= chunkLoadingInterval then
		sendChunkLoad()
		lastChunkLoad = currentTime
	end
	
	-- Handle timer events (cleanup)
	local event, timerId = os.pullEvent("timer")
	if timerId == timer then
		-- Timer expired, continue loop
	end
end
