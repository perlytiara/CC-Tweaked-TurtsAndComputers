-- tClear_listener.lua
-- Run this on EACH turtle that should accept remote tClear jobs via rednet

-- Auto-detect a modem and open rednet
local function findModem()
	for _, p in pairs(rs.getSides()) do
		if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
			return p
		end
	end
	error("No modem attached to this turtle.")
end

local modemSide = findModem()
rednet.open(modemSide)

local wrapped = peripheral.wrap(modemSide)
if wrapped and wrapped.isWireless and not wrapped.isWireless() then
	print("Note: Wired modem detected. Ensure this turtle is networked to the computer.")
end

local thisId = os.getComputerID()
print("tClear listener active. Turtle ID: " .. tostring(thisId))
print("Waiting for tClear jobs...")

local function parseAndRun(message)
	-- Accept both structured tables and plain strings
	local argsString = nil
	if type(message) == "table" then
		if message.command == "RUN" and (message.program == "tClear" or message.program == "tclear") then
			argsString = tostring(message.args or "")
		elseif message.command == "RUN" and message.program == "tClearChunky" then
			-- Handle chunky turtle requests
			print("Starting chunky turtle mode...")
			local ok, err = pcall(function()
				shell.run("tClearChunky")
			end)
			if not ok then
				print("tClearChunky failed: " .. tostring(err))
				return false, err
			end
			return true
		else
			-- Unknown table; ignore
			return false, "unsupported-table"
		end
	elseif type(message) == "string" then
		argsString = message
	else
		return false, "unsupported-type"
	end

	argsString = argsString or ""
	argsString = argsString:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	if argsString == "" then
		return false, "empty-args"
	end

	print("Starting: tClear " .. argsString)
	local ok, err = pcall(function()
		shell.run("tClear " .. argsString)
	end)
	if not ok then
		print("tClear failed: " .. tostring(err))
		return false, err
	end
	return true
end

-- Main receive loop
while true do
	local senderId, message, protocol = rednet.receive()
	-- Only act on messages that look like ours
	local handled = false
	if protocol == nil or protocol == "tclear-run" or protocol == "tclear" or protocol == "tclear-chunky" then
		local ok = false
		ok = select(1, parseAndRun(message))
		handled = ok
	end

	if not handled then
		-- Try a plain string fallback even without protocol
		if type(message) == "string" then
			local ok = select(1, parseAndRun(message))
			handled = ok
		end
	end

	if handled then
		rednet.send(senderId, { status = "ok", id = thisId }, "tclear-ack")
	else
		-- Not for us; ignore silently
	end
end


