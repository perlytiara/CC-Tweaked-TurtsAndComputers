--[[
	Room Carver (lean)
	Start position: place turtle at the room's bottom-left corner, on floor level, facing into the room.
	Goal: carve a rectangular room using efficient reach (minimal vertical moves), place torches, and auto-trash matching items when full.
]]--

local version = "2.2"

-- UI helpers (minimal)
local function ask_number_default(prompt, default_value, min_val, max_val)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Room Carver v"..version.."\n\n")
		write(string.format("%s [default: %s] ", prompt, tostring(default_value)))
		local s = read(); if s == nil or s == "" then return default_value end
		local n = tonumber(s)
		if n and (not min_val or n >= min_val) and (not max_val or n <= max_val) then return n end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end
local function ask_yes_no(prompt, default_yes)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Room Carver v"..version.."\n\n")
		local def = default_yes and "Y" or "N"
		write(string.format("%s (y/n) [default: %s] ", prompt, def))
		local s = read(); s = s and string.lower(s) or ""
		if s == "" then return default_yes end
		if s == "y" or s == "yes" then return true end
		if s == "n" or s == "no" then return false end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end

-- Movement/helpers
local current_fuel_slot = 2
local heading_index = 0 -- 0:+Z, 1:+X, 2:-Z, 3:-X
local function turn_left() turtle.turnLeft(); heading_index = (heading_index + 3) % 4 end
local function turn_right() turtle.turnRight(); heading_index = (heading_index + 1) % 4 end
local function face_dir(target)
	local diff = (target - heading_index) % 4
	if diff == 1 then turn_right()
	elseif diff == 2 then turn_right(); turn_right()
	elseif diff == 3 then turn_left() end
end
local function ensure_fuel(minimum)
	if turtle.getFuelLevel()=="unlimited" then return end
	if turtle.getFuelLevel()>=minimum then return end
	-- Prefer configured fuel slot first
	if current_fuel_slot and current_fuel_slot>=1 and current_fuel_slot<=16 then
		turtle.select(current_fuel_slot)
		if turtle.refuel(0) then while turtle.getFuelLevel()<minimum and turtle.refuel(1) do end end
		if turtle.getFuelLevel()>=minimum then return end
	end
	-- Fallback: try all slots
	for i=1,16 do turtle.select(i); if turtle.refuel(0) then while turtle.getFuelLevel()<minimum and turtle.refuel(1) do end; if turtle.getFuelLevel()>=minimum then return end end end
	term.clear(); term.setCursorPos(1,1); print("Out of fuel. Add fuel and press Enter."); read(); return ensure_fuel(minimum)
end
local function dig_forward() while turtle.detect() do if not turtle.dig() then turtle.attack(); sleep(0.05) end end end
local function dig_up() while turtle.detectUp() do if not turtle.digUp() then turtle.attackUp(); sleep(0.05) end end end
local function dig_down() while turtle.detectDown() do if not turtle.digDown() then turtle.attackDown(); sleep(0.05) end end end
local function safe_forward() ensure_fuel(100); while not turtle.forward() do dig_forward(); sleep(0.02) end end
local function safe_up() ensure_fuel(100); while not turtle.up() do dig_up(); sleep(0.02) end end
local function safe_down() ensure_fuel(100); while not turtle.down() do dig_down(); sleep(0.02) end end
local function step_right() turn_right(); dig_forward(); safe_forward(); turn_left() end
local function step_left() turn_left(); dig_forward(); safe_forward(); turn_right() end

-- Inventory helpers
local function empty_slots()
	local e=0; for i=1,16 do if turtle.getItemCount(i)==0 then e=e+1 end end; return e
end
local function any_match(sample_slot)
	if not sample_slot or turtle.getItemCount(sample_slot)==0 then return false end
	for i=1,16 do if i~=sample_slot and turtle.getItemCount(i)>0 then turtle.select(i); if turtle.compareTo(sample_slot) then return true end end end
	return false
end
local function drop_matching_front(sample_slot)
	if not sample_slot or turtle.getItemCount(sample_slot)==0 then return end
	for i=1,16 do
		if i~=sample_slot and turtle.getItemCount(i)>0 then
			turtle.select(i)
			if turtle.compareTo(sample_slot) then dig_forward(); turtle.drop() end
		end
	end
end

-- Persistent resume state
local function state_path()
	local dir = ".room_carver"; if not fs.exists(dir) then fs.makeDir(dir) end; return fs.combine(dir, "state")
end
local function save_state(st)
	st.heading_index = heading_index
	local p = state_path()
	local h = fs.open(p, "w"); if not h then return end
	h.write(textutils.serialize(st))
	h.close()
end
local function load_state()
	local p = state_path(); if not fs.exists(p) then return nil end
	local h = fs.open(p, "r"); if not h then return nil end
	local d = h.readAll(); h.close()
	local ok, t = pcall(textutils.unserialize, d)
	if ok and type(t)=="table" then return t end
	return nil
end
local function clear_state()
	local p = state_path(); if fs.exists(p) then fs.delete(p) end
end

-- Torch placement on side wall we are adjacent to (left if at x==1, right if at x==width)
local function place_torch_on_wall(torch_slot, on_left)
	if torch_slot<=0 or turtle.getItemCount(torch_slot)==0 then return end
	turtle.select(torch_slot)
	if on_left then turn_left() else turn_right() end
	local ok=turtle.place()
	if not ok then dig_forward(); ok=turtle.place() end
	if on_left then turn_right() else turn_left() end
end

-- Traverse helpers
local function lawn_step_side(to_right)
	if to_right then step_right() else step_left() end
end
local function advance_row()
	-- Ensure we move along current forward Z direction
	dig_forward(); safe_forward()
end

-- Inventory + IO helpers for capacity and chest dump
local function ensure_capacity(sample_slot)
	if sample_slot and empty_slots()==0 and any_match(sample_slot) then drop_matching_front(sample_slot) end
end
local function turn_to_side(side) if side=="left" then turn_left() else turn_right() end end
local function place_chest_in_wall(chest_slot, side)
	if chest_slot<=0 or turtle.getItemCount(chest_slot)==0 then return false end
	turn_to_side(side)
	dig_forward()
	turtle.select(chest_slot)
	local ok=turtle.place()
	if not ok then dig_forward(); ok=turtle.place() end
	turn_to_side(side=="left" and "right" or "left")
	return ok
end
local function deposit_into_front(reserved_slots)
	for i=1,16 do
		if not reserved_slots[i] and turtle.getItemCount(i)>0 then
			turtle.select(i)
			if not turtle.refuel(0) then turtle.drop() end
		end
	end
end
local function ensure_inventory_capacity(cfg, at_left)
	if empty_slots()>0 then return end
	-- First try throwing matches
	if cfg.use_throw and any_match(cfg.throw_slot) then drop_matching_front(cfg.throw_slot); if empty_slots()>0 then return end end
	-- Then try chests
	if cfg.use_chests and turtle.getItemCount(cfg.chest_slot)>0 then
		local side = at_left and "left" or "right"
		if place_chest_in_wall(cfg.chest_slot, side) then
			-- Face chest now; deposit everything except reserved slots
			turn_to_side(side)
			local reserved = {}
			reserved[cfg.fuel_slot]=true; reserved[cfg.chest_slot]=true; reserved[cfg.torch_slot]=true; reserved[cfg.throw_slot]=true
			deposit_into_front(reserved)
			-- Keep exactly 1 item in throw sample slot if present
			if cfg.use_throw and turtle.getItemCount(cfg.throw_slot)>1 then
				turtle.select(cfg.throw_slot); turtle.drop(turtle.getItemCount(cfg.throw_slot)-1)
			end
			turn_to_side(side=="left" and "right" or "left")
		end
	end
end

-- Optimized row drilling: turn once per row, traverse along X, turn back to +Z
local function advance_row_z(z_forward)
	face_dir(z_forward and 0 or 2)
	dig_forward(); safe_forward()
end

-- Returns whether we ended on the right edge
local function line_snake_traverse(width, depth, per_cell_fn, on_row_start, start_from_right, z_forward)
	local going_right = not start_from_right
	for zi=1,depth do
		local row_from_front = z_forward and zi or (depth - zi + 1)
		if on_row_start then on_row_start(row_from_front, going_right) end
		-- Face along X for this row
		face_dir(going_right and 1 or 3) -- 1:+X, 3:-X
		for x=1,width do
			per_cell_fn(x, row_from_front, going_right)
			if x<width then dig_forward(); safe_forward() end
		end
		-- Advance to next row along Z
		if zi<depth then advance_row_z(z_forward) end
		going_right = not going_right
	end
	-- Determine ending edge: after depth rows, if depth is odd we end opposite of start edge
	local ended_right = (depth % 2 == 0) and start_from_right or (not start_from_right)
	return ended_right
end

-- Multi-band carve to support arbitrary height
local function carve_room(width, depth, height, cfg)
	if height < 2 then height = 2 end
	local bands
	if height == 2 then bands = 1 else bands = math.ceil((height-1)/2) end
	-- Move to working level for first band
	if height >= 3 then safe_up() end
	local start_from_right = cfg.resume_start_from_right or false -- band 1 starts at left edge by default
	local z_forward = (cfg.resume_z_forward==false) and false or true -- default forward
	local start_band = cfg.resume_band or 1
	local start_row = cfg.resume_row or 1
	for b=start_band,bands do
		local skip_up = (height >= 3) and (b == bands) and ((2*b + 1) > height)
		local function per_cell_fn(x, z, going_right)
			-- Keep inventory flowing
			ensure_inventory_capacity(cfg, going_right)
			-- Clear vertical for this cell using reach
			if height == 2 then
				dig_up()
			else
				dig_down(); if not skip_up then dig_up() end
			end
		end
		local function on_row_start(z, going_right)
			-- Capacity check at row start
			ensure_inventory_capacity(cfg, going_right)
			-- Torches only on first band
			if b==1 and cfg.use_torches and cfg.torch_spacing>0 and (z % cfg.torch_spacing == 0) then
				place_torch_on_wall(cfg.torch_slot, going_right)
			end
			-- Fuel guard: small rolling reserve based on remaining rows and columns
			local remaining_rows = z_forward and (depth - z + 1) or (z)
			local reserve = math.max(40, remaining_rows + width + 10)
			ensure_fuel(reserve)
			-- Persist state at row boundary
			save_state({width=width, depth=depth, height=height, band=b, row=z, start_from_right=start_from_right, z_forward=z_forward})
		end
		-- Traverse this band from the correct corner and along proper Z direction
		local depth_remaining = (b==start_band) and (depth - (start_row-1)) or depth
		local ended_right = line_snake_traverse(width, depth_remaining, per_cell_fn, on_row_start, start_from_right, z_forward)
		-- Move up to next band
		if b < bands then safe_up(); safe_up() end
		-- Prepare next band start: flip Z direction and set start edge to where we ended
		start_from_right = ended_right
		z_forward = not z_forward
		start_row = 1
	end
	-- Clear state when finished
	clear_state()
end

local function main()
	term.clear(); term.setCursorPos(1,1)
	print("Room Carver v"..version)
	print("Start at bottom-left, on floor, facing into room.")

	-- Favorites
	local function favorite_path() local dir = ".room_carver"; if not fs.exists(dir) then fs.makeDir(dir) end; return fs.combine(dir, "favorite") end
	local function load_favorite()
		local p=favorite_path(); if not fs.exists(p) then return nil end
		local h=fs.open(p,"r"); if not h then return nil end
		local d=h.readAll(); h.close(); local ok,t=pcall(textutils.unserialize,d); if ok and type(t)=="table" then return t end; return nil
	end
	local function save_favorite(tbl)
		local p=favorite_path(); local h=fs.open(p,"w"); if not h then return end; h.write(textutils.serialize(tbl)); h.close()
	end

	local fav = load_favorite()
	local use_fav = fav and ask_yes_no("Use favorite saved config?", true) or false

	local width, depth, height
	local use_torches, torch_spacing, torch_slot
	local use_throw, throw_slot
	local use_chests, chest_slot
	local fuel_slot

	if use_fav then
		width=fav.width or 9; depth=fav.depth or 9; height=fav.height or 3
		use_torches = fav.use_torches~=false; torch_spacing=fav.torch_spacing or 9; torch_slot=fav.torch_slot or 1
		use_throw = fav.use_throw~=false; throw_slot=fav.throw_slot or 4
		use_chests = fav.use_chests~=false; chest_slot=fav.chest_slot or 3
		fuel_slot = fav.fuel_slot or 2
	else
		width = ask_number_default("Room width (X):", 9, 1, 199)
		depth = ask_number_default("Room depth (Z):", 9, 1, 199)
		height = ask_number_default("Room height (>=2):", 3, 2, 32)
		use_torches = ask_yes_no("Place torches?", true)
		if use_torches then
			torch_spacing = ask_number_default("Torch spacing (rows):", 9, 1, 64)
			torch_slot = ask_number_default("Torch slot:", 1, 1, 16)
		else
			torch_spacing = 0; torch_slot = 1
		end
		use_throw = ask_yes_no("Auto-throw matching items when full?", true)
		throw_slot = ask_number_default("Sample slot to match:", 4, 1, 16)
		use_chests = ask_yes_no("Place chest to dump when full?", true)
		chest_slot = ask_number_default("Chest slot:", 3, 1, 16)
		fuel_slot = ask_number_default("Fuel slot:", 2, 1, 16)
		if ask_yes_no("Save as favorite?", true) then
			save_favorite({width=width,depth=depth,height=height,use_torches=use_torches,torch_spacing=torch_spacing,torch_slot=torch_slot,use_throw=use_throw,throw_slot=throw_slot,use_chests=use_chests,chest_slot=chest_slot,fuel_slot=fuel_slot})
		end
	end

	current_fuel_slot = fuel_slot or 2

	-- Attempt to resume from saved state if present; ask before using it
	local st = load_state()
	if st and st.width==width and st.depth==depth and st.height==height then
		local prompt = string.format("Found saved progress for this size: band %d, row %d. Restore?", st.band or 1, st.row or 1)
		local restore = ask_yes_no(prompt, true)
		if not restore then
			clear_state()
			st = nil
		end
	end

	term.clear(); term.setCursorPos(1,1)
	print("Room Carver v"..version)
	print("Size:", width, "x", depth, " height:", height)
	if use_torches then print("Torches every", torch_spacing, "rows from slot", torch_slot) else print("Torches: off") end
	print("Fuel slot:", current_fuel_slot)
	print("Chest dump:", use_chests and ("slot "..(chest_slot or 3)) or "off")
	print("Auto-throw:", use_throw and ("sample slot "..(throw_slot or 4)) or "off")
	print("Press Enter to start...")
	read()

	-- Estimate minimal fuel and ensure (soft check; we now check per-row too)
	local est_moves = (width*depth) * math.max(1, math.ceil((height-1)/2)) * 2 + depth + width
	ensure_fuel(math.min(est_moves + 50, 500))

	-- State (if any) was already handled above

	-- Carve with full configuration
	carve_room(width, depth, height, {
		use_torches=use_torches,
		torch_spacing=torch_spacing or 0,
		torch_slot=torch_slot or 1,
		use_throw=use_throw,
		throw_slot=throw_slot or 4,
		use_chests=use_chests,
		chest_slot=chest_slot or 3,
		fuel_slot=current_fuel_slot,
		-- resume hints
		resume_band = st and st.band or 1,
		resume_row = st and st.row or 1,
		resume_start_from_right = st and st.start_from_right or false,
		resume_z_forward = st and (st.z_forward~=false)
	})

	term.clear(); term.setCursorPos(1,1)
	print("Done. Room completed.")
end

main()
