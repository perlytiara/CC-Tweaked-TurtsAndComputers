-- EMT Pocket Monitor
-- Monitors EpicMiningTurtle progress/inventory over rednet and can send simple commands

local PROTOCOL = "EMT"
local tracked_id = nil
local last = nil
local last_time = 0

local function open_modem()
	local opened = false
	if peripheral and rednet then
		peripheral.find("modem", function(side, modem)
			if modem.isWireless and modem.isWireless() then
				if not rednet.isOpen(side) then rednet.open(side) end
				opened = true
			end
		end)
		if not opened then
			peripheral.find("modem", function(side)
				if not rednet.isOpen(side) then rednet.open(side) end
				opened = true
			end)
		end
	end
	return opened
end

local function draw()
	term.clear()
	term.setCursorPos(1,1)
	write("EMT Pocket Monitor")
	term.setCursorPos(1,2)
	write("Tracking: "..(tracked_id and (tostring(tracked_id).." (set)") or "auto"))
	term.setCursorPos(1,3)
	if last then
		write("From #"..tostring(last.sender_id).." "..(last.label or "").."  fuel:"..tostring(last.fuel))
		term.setCursorPos(1,4)
		local p = last.progress or {}
		write("Tunnel "..tostring(p.current_tunnel or 0).."/"..tostring(p.total_tunnels or 0).."  Layer "..tostring(p.current_layer or 0).."/"..tostring(p.total_layers or 0))
		term.setCursorPos(1,5)
		local pos = last.pos
		if pos then
			write("Pos: x="..math.floor(pos.x+0.5).." y="..math.floor(pos.y+0.5).." z="..math.floor(pos.z+0.5))
		else
			write("Pos: (no GPS)")
		end
		term.setCursorPos(1,6)
		write("Last: "..(last.kind or "status").." at t="..tostring(last_time))
		term.setCursorPos(1,8)
		write("Inventory:")
		local row = 9
		if last.inventory and #last.inventory > 0 then
			for i=1, math.min(#last.inventory, 8) do
				local it = last.inventory[i]
				term.setCursorPos(1,row)
				write(string.format("%2d: %-20s x%3d", it.slot, (it.name or "?"), (it.count or 0)))
				row = row + 1
			end
		else
			term.setCursorPos(1,row)
			write("(empty)")
		end
	else
		write("Waiting for turtle...")
	end
	term.setCursorPos(1,18)
	write("Keys: [S]et monitor  [R]efresh  [P]ickup  [Q]uit")
end

local function send_command(id, cmd)
	if not id then return end
	rednet.send(id, {command=cmd}, PROTOCOL)
end

local function handle_msg(id, msg)
	if type(msg) ~= "table" then return end
	if msg.kind == "start" or msg.kind == "status" or msg.kind == "heartbeat" or msg.kind == "progress" or msg.kind == "inventory" or msg.kind == "tunnel_complete" or msg.kind == "done" or msg.kind == "pickup" then
		last = msg
		last_time = os.clock()
		if not tracked_id then tracked_id = id end
		draw()
		if msg.kind == "done" then
			for i=1,3 do
				if term and term.blit then
					term.setCursorPos(1,7)
					write("Turtle DONE!")
				end
				os.sleep(0.1)
			end
		end
	end
end

local function main()
	if not open_modem() then
		print("No modem found")
		return
	end
	draw()
	-- Ask any turtles for current status
	rednet.broadcast({command="request_status"}, PROTOCOL)
	while true do
		local e = { os.pullEvent() }
		local ev = e[1]
		if ev == "rednet_message" then
			local id, msg, proto = e[2], e[3], e[4]
			if proto == PROTOCOL then
				handle_msg(id, msg)
			end
		elseif ev == "key" then
			local key = e[2]
			if key == keys.q then
				break
			elseif key == keys.r then
				if tracked_id then send_command(tracked_id, "request_status") else rednet.broadcast({command="request_status"}, PROTOCOL) end
				draw()
			elseif key == keys.p then
				if tracked_id then send_command(tracked_id, "request_pickup") end
				draw()
			elseif key == keys.s then
				if last and last.sender_id then
					tracked_id = last.sender_id
					send_command(tracked_id, "set_monitor")
				end
				draw()
			end
		end
	end
end

main()



