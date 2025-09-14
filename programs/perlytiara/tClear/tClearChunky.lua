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
local blnDebugPrint = true

---------------------------------------
---- VARIABLES: specific -------------- 
---------------------------------------
local masterTurtleId = nil
local chunkLoadingInterval = 2 -- seconds between chunk loading signals
local position = {x = 0, y = 0, z = -1, facing = 0} -- relative to master (to the left)
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
local function moveTo(targetX, targetY, targetZ, targetFacing)
	-- Calculate relative movement needed from current position to target
	local dx = targetX - position.x
	local dy = targetY - position.y
	local dz = targetZ - position.z
	local dfacing = (targetFacing - position.facing) % 4
	
	debugPrint("Moving from (" .. position.x .. "," .. position.y .. "," .. position.z .. ") to (" .. targetX .. "," .. targetY .. "," .. targetZ .. ")")
	debugPrint("Delta: dx=" .. dx .. " dy=" .. dy .. " dz=" .. dz .. " dfacing=" .. dfacing)
	
	-- Turn to correct facing first
	if dfacing == 1 then
		turtle.turnRight()
		position.facing = (position.facing + 1) % 4
	elseif dfacing == 2 then
		turtle.turnRight()
		turtle.turnRight()
		position.facing = (position.facing + 2) % 4
	elseif dfacing == 3 then
		turtle.turnLeft()
		position.facing = (position.facing - 1) % 4
	end
	
	-- Move vertically first
	while dy > 0 do
		if turtle.up() then
			dy = dy - 1
			position.y = position.y + 1
			debugPrint("Moved up to y=" .. position.y)
		else
			debugPrint("Cannot move up, blocked")
			break
		end
	end
	while dy < 0 do
		if turtle.down() then
			dy = dy + 1
			position.y = position.y - 1
			debugPrint("Moved down to y=" .. position.y)
		else
			debugPrint("Cannot move down, blocked")
			break
		end
	end
	
	-- Move horizontally - handle X movement (forward/backward relative to facing)
	while dx > 0 do
		-- Try to dig if blocked, but don't get stuck
		if not turtle.forward() then
			debugPrint("Blocked, trying to dig forward")
			turtle.dig()
			sleep(0.1) -- Brief pause after digging
			if turtle.forward() then
				dx = dx - 1
				position.x = position.x + 1
				debugPrint("Moved forward to x=" .. position.x)
			else
				debugPrint("Still blocked after digging, giving up")
				break
			end
		else
			dx = dx - 1
			position.x = position.x + 1
			debugPrint("Moved forward to x=" .. position.x)
		end
	end
	while dx < 0 do
		-- Turn around to move backward
		turtle.turnLeft()
		turtle.turnLeft()
		if not turtle.forward() then
			debugPrint("Blocked, trying to dig backward")
			turtle.dig()
			sleep(0.1)
			if turtle.forward() then
				dx = dx + 1
				position.x = position.x - 1
				debugPrint("Moved backward to x=" .. position.x)
			else
				debugPrint("Still blocked after digging backward, giving up")
			end
		else
			dx = dx + 1
			position.x = position.x - 1
			debugPrint("Moved backward to x=" .. position.x)
		end
		turtle.turnLeft()
		turtle.turnLeft()
		if dx < 0 then break end -- If still can't move, give up
	end
	
	-- Move sideways - handle Z movement (left/right relative to facing)
	while dz > 0 do
		turtle.turnRight()
		if not turtle.forward() then
			debugPrint("Blocked, trying to dig right")
			turtle.dig()
			sleep(0.1)
			if turtle.forward() then
				dz = dz - 1
				position.z = position.z + 1
				debugPrint("Moved right to z=" .. position.z)
			else
				debugPrint("Still blocked after digging right")
			end
		else
			dz = dz - 1
			position.z = position.z + 1
			debugPrint("Moved right to z=" .. position.z)
		end
		turtle.turnLeft()
		if dz > 0 then break end -- If still can't move, give up
	end
	while dz < 0 do
		turtle.turnLeft()
		if not turtle.forward() then
			debugPrint("Blocked, trying to dig left")
			turtle.dig()
			sleep(0.1)
			if turtle.forward() then
				dz = dz + 1
				position.z = position.z - 1
				debugPrint("Moved left to z=" .. position.z)
			else
				debugPrint("Still blocked after digging left")
			end
		else
			dz = dz + 1
			position.z = position.z - 1
			debugPrint("Moved left to z=" .. position.z)
		end
		turtle.turnRight()
		if dz < 0 then break end -- If still can't move, give up
	end
	
	-- Update final facing
	position.facing = targetFacing
	debugPrint("Final position: (" .. position.x .. "," .. position.y .. "," .. position.z .. ") facing=" .. position.facing)
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
	if message.type == "find_chunky" then
		-- Master turtle is looking for chunky turtles
		print("Master turtle " .. (message.masterId or "unknown") .. " is looking for chunky turtles")
		-- Send response
		rednet.send(message.masterId, {
			type = "chunky_available",
			id = os.getComputerID(),
			timestamp = os.time()
		}, "tclear-chunky")
		print("Sent response to master turtle")
		return true
		
	elseif message.type == "pair" then
		masterTurtleId = message.masterId
		isActive = true
		print("SUCCESS: Paired with master turtle " .. masterTurtleId)
		print("Chunky turtle is now active and ready to follow!")
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

print("Sent initial broadcast - waiting for master turtle...")

-- Main loop
local lastChunkLoad = 0
local lastBroadcast = 0
local broadcastInterval = 5 -- Send broadcast every 5 seconds

while true do
	local timer = os.startTimer(0.1) -- Check for messages every 0.1 seconds
	
	-- Handle rednet messages
	local senderId, message, protocol = rednet.receive(0.1)
	if senderId then
		-- Accept messages on multiple protocols
		if protocol == "tclear-chunky" or protocol == "tclear-run" or protocol == "tclear" or protocol == nil then
			local handled = processMessage(message)
			if handled then
				print("Processed message from " .. senderId)
			end
		end
	end
	
	-- Send chunk loading signal periodically
	local currentTime = os.time()
	if isActive and (currentTime - lastChunkLoad) >= chunkLoadingInterval then
		sendChunkLoad()
		lastChunkLoad = currentTime
	end
	
	-- Send periodic broadcasts if not paired yet
	if not isActive and (currentTime - lastBroadcast) >= broadcastInterval then
		rednet.broadcast({
			type = "chunky_available",
			id = thisId,
			timestamp = currentTime
		}, "tclear-chunky")
		print("Sent broadcast - still waiting for master turtle...")
		lastBroadcast = currentTime
	end
	
	-- Handle timer events (cleanup)
	local event, timerId = os.pullEvent("timer")
	if timerId == timer then
		-- Timer expired, continue loop
	end
end
