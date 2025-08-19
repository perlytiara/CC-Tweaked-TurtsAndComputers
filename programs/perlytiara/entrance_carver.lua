--[[
	Entrance Carver by Silvamord
	Carves a rectangular entrance corridor with configurable width, height (above/below floor), and length.
	Start modes:
	- center: turtle stands at center column of doorway
	- bottom-left: turtle stands at doorway's bottom-left corner

	Features: torches (left/right/both, spacing), chest dump, throw items by sample, favorite config, auto-return for fuel along corridor.
]]--

local version = "1.0"

-- UI helpers
local function ask_number_default(prompt, default_value, min_val, max_val)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Entrance Carver v"..version.."\n\n")
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
		write("Entrance Carver v"..version.."\n\n")
		local def = default_yes and "Y" or "N"
		write(string.format("%s (y/n) [default: %s] ", prompt, def))
		local s = read(); s = s and string.lower(s) or ""
		if s == "" then return default_yes end
		if s == "y" or s == "yes" then return true end
		if s == "n" or s == "no" then return false end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end

local function ask_choice(prompt, default_value, choices)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Entrance Carver v"..version.."\n\n")
		write(string.format("%s %s [default: %s] ", prompt, table.concat(choices, "/"), tostring(default_value)))
		local s = read(); if s == nil or s == "" then return default_value end
		s = string.lower(s)
		for _, c in ipairs(choices) do if s == c then return s end end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end

-- Movement helpers
local function ensure_fuel(threshold)
	if turtle.getFuelLevel() == "unlimited" then return end
	if turtle.getFuelLevel() >= threshold then return end
	for i=1,16 do
		turtle.select(i)
		if turtle.refuel(0) then while turtle.getFuelLevel()<threshold and turtle.refuel(1) do end; if turtle.getFuelLevel()>=threshold then return end end
	end
	term.clear(); term.setCursorPos(1,1); print("Out of fuel. Add fuel and press Enter."); read();
	return ensure_fuel(threshold)
end

local function dig_forward() while turtle.detect() do if not turtle.dig() then turtle.attack(); sleep(0.1) end end end
local function dig_upwards() while turtle.detectUp() do if not turtle.digUp() then turtle.attackUp(); sleep(0.1) end end end
local function dig_downwards() while turtle.detectDown() do if not turtle.digDown() then turtle.attackDown(); sleep(0.1) end end end

local function safe_forward() ensure_fuel(100); while not turtle.forward() do dig_forward(); sleep(0.05) end end
local function safe_up() ensure_fuel(100); while not turtle.up() do dig_upwards(); sleep(0.05) end end
local function safe_down() ensure_fuel(100); while not turtle.down() do dig_downwards(); sleep(0.05) end end

local function turn_left() turtle.turnLeft() end
local function turn_right() turtle.turnRight() end
local function step_right() turn_right(); dig_forward(); safe_forward(); turn_left() end
local function step_left() turn_left(); dig_forward(); safe_forward(); turn_right() end

-- Favorites
local function favorite_path()
	local dir = ".entrance_carver"; if not fs.exists(dir) then fs.makeDir(dir) end
	return fs.combine(dir, "favorite")
end
local function load_favorite()
	local p = favorite_path(); if not fs.exists(p) then return nil end
	local h = fs.open(p, "r"); if not h then return nil end; local d=h.readAll(); h.close()
	local ok,t = pcall(textutils.unserialize,d); if ok and type(t)=="table" then return t end; return nil
end
local function save_favorite(tbl)
	local p = favorite_path(); local h = fs.open(p,"w"); if not h then return end; h.write(textutils.serialize(tbl)); h.close()
end

-- Inventory & IO
local function count_empty_slots() local e=0; for i=1,16 do if turtle.getItemCount(i)==0 then e=e+1 end end; return e end
local function any_item_matches_slot(slot_idx)
	if turtle.getItemCount(slot_idx)==0 then return false end
	for i=1,16 do if i~=slot_idx and turtle.getItemCount(i)>0 then turtle.select(i); if turtle.compareTo(slot_idx) then return true end end end
	return false
end
local function drop_matching_front(slot_idx)
	for i=1,16 do if i~=slot_idx and turtle.getItemCount(i)>0 then turtle.select(i); if turtle.compareTo(slot_idx) then turtle.drop() end end end
end
local function turn_to_side(side) if side=="left" then turn_left() else turn_right() end end
local function place_chest_in_wall(chest_slot, side)
	if turtle.getItemCount(chest_slot)==0 then return false end
	turn_to_side(side); dig_forward(); turtle.select(chest_slot)
	local ok = turtle.place(); if not ok then dig_forward(); ok = turtle.place() end; if not ok then ok = turtle.placeDown() end
	turn_to_side(side=="left" and "right" or "left"); return ok
end
local function deposit_into_front(chest_slot, torch_slot, throw_slot)
	for i=1,16 do if i~=chest_slot and i~=torch_slot and i~=throw_slot and turtle.getItemCount(i)>0 then turtle.select(i); if not turtle.refuel(0) then turtle.drop() end end end
	if throw_slot then local cnt=turtle.getItemCount(throw_slot); if cnt>1 then turtle.select(throw_slot); turtle.drop(cnt-1) end end
end
local function ensure_inventory_capacity(cfg, at_left)
	if count_empty_slots()>0 then return end
	if cfg.use_throw and turtle.getItemCount(cfg.throw_slot)>0 and any_item_matches_slot(cfg.throw_slot) then
		drop_matching_front(cfg.throw_slot); if count_empty_slots()>0 then return end
	end
	if cfg.use_chests then local side = at_left and "left" or "right"; if place_chest_in_wall(cfg.chest_slot, side) then deposit_into_front(cfg.chest_slot, cfg.torch_slot, cfg.throw_slot) end end
end

-- Torches
local function place_torch_if_needed(step_idx, cfg, width, at_left)
	if not cfg.use_torches or cfg.torch_spacing<=0 then return end
	if step_idx % cfg.torch_spacing ~= 0 then return end
	if turtle.getItemCount(cfg.torch_slot)==0 then return end
	local function place_on(side)
		local climbed = 0; if width>=3 then safe_up(); climbed=1 end
		turn_to_side(side); turtle.select(cfg.torch_slot)
		local ok = turtle.place(); if not ok then turn_to_side(side=="left" and "right" or "left"); for i=1,climbed do safe_down() end; turtle.select(cfg.torch_slot); turtle.placeDown(); return end
		turn_to_side(side=="left" and "right" or "left"); for i=1,climbed do safe_down() end
	end
	if cfg.torch_side=="both" then if at_left then place_on("left"); place_on("right") else place_on("right"); place_on("left") end else place_on(cfg.torch_side) end
end

-- Carve one corridor slice at current face, optimized using level-2 reach
local function carve_slice(width, above, below, start_at_left, current_level)
	local work_level = (above>=2) and 2 or 1
	if (current_level or 1) < work_level then while (current_level or 1) < work_level do safe_up(); current_level=(current_level or 1)+1 end end
	if (current_level or 1) > work_level then while (current_level or 1) > work_level do safe_down(); current_level=(current_level or 1)-1 end end
	local end_at_left
	if start_at_left then
		for x=1,width do
			if work_level==1 then dig_forward() else turtle.digDown(); if above>=2 then dig_upwards() end end
			if x<width then step_right() end
		end
		end_at_left=false
	else
		for x=width,1,-1 do
			if work_level==1 then dig_forward() else turtle.digDown(); if above>=2 then dig_upwards() end end
			if x>1 then step_left() end
		end
		end_at_left=true
	end
	if above>=3 then safe_up(); if start_at_left then for x=1,width do dig_upwards(); if x<width then step_right() end end else for x=width,1,-1 do dig_upwards(); if x>1 then step_left() end end end; safe_down() end
	if below>=1 then if work_level==2 then safe_down() end; if start_at_left then for x=1,width do turtle.digDown(); if x<width then step_right() end end else for x=width,1,-1 do turtle.digDown(); if x>1 then step_left() end end end; if work_level==2 then safe_up() end end
	return end_at_left, work_level
end

local function estimate_moves_per_slice(width, above, below)
	local vertical = (above>=2) and 1 or 0; if above>=3 then vertical=vertical+2 end; if below>=1 and above>=2 then vertical=vertical+2 end
	local lateral = (width-1)
	local advance = 1
	return vertical + lateral + advance
end

local function attempt_return_for_refuel(depth, reserve_needed)
	local minimal = depth*2 + 4
	if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < minimal then ensure_fuel(minimal) end
	turn_right(); turn_right(); for i=1,depth do safe_forward() end
	term.clear(); term.setCursorPos(1,1); print("At start. Add fuel/torches, press Enter."); read()
	ensure_fuel(reserve_needed)
	turn_right(); turn_right(); for i=1,depth do safe_forward() end
end

local function main()
	term.clear(); term.setCursorPos(1,1); print("Entrance Carver v"..version); print("Place turtle at doorway, facing wall.")
	local fav = load_favorite(); local use_fav = fav and ask_yes_no("Use favorite saved config?", true) or false

	local start_mode, width, length, above, below
	local use_torches, torch_spacing, torch_side, torch_slot
	local use_chests, chest_slot
	local use_throw, throw_slot
	local auto_return

	if use_fav then
		start_mode = fav.start_mode or "center"
		width = fav.width or 5; length = fav.length or 16; above = fav.above or 3; below = fav.below or 0
		auto_return = fav.auto_return or true
		use_torches = fav.use_torches or true; torch_spacing = fav.torch_spacing or 9; torch_side = fav.torch_side or "both"; torch_slot = fav.torch_slot or 1
		use_chests = fav.use_chests or true; chest_slot = fav.chest_slot or 2
		use_throw = fav.use_throw or false; throw_slot = fav.throw_slot or 4
	else
		start_mode = ask_choice("Start mode:", "center", {"center","bottom-left"})
		width = ask_number_default("Doorway width:", 5, 1, 64)
		length = ask_number_default("Entrance length:", 16, 1, 100000)
		above = ask_number_default("Height above floor:", 3, 1, 16)
		below = ask_number_default("Height below floor:", 0, 0, 8)
		auto_return = ask_yes_no("Auto-return for fuel/torches?", true)
		use_torches = ask_yes_no("Place torches?", true)
		if use_torches then torch_spacing = ask_number_default("Torch spacing (blocks):", 9, 1, 64); torch_side = ask_choice("Torch side:", "both", {"left","right","both"}); torch_slot = ask_number_default("Torch slot (1-16):", 1, 1, 16) else torch_spacing=0; torch_side="right"; torch_slot=1 end
		use_chests = ask_yes_no("Place chests to dump when full?", true); if use_chests then chest_slot = ask_number_default("Chest slot (1-16):", 2, 1, 16) else chest_slot = 2 end
		use_throw = ask_yes_no("Throw items matching a sample when full?", false); if use_throw then throw_slot = ask_number_default("Sample slot (1-16):", 4, 1, 16) else throw_slot = 4 end
		if ask_yes_no("Save as favorite?", true) then save_favorite({start_mode=start_mode,width=width,length=length,above=above,below=below,auto_return=auto_return,use_torches=use_torches,torch_spacing=torch_spacing,torch_side=torch_side,torch_slot=torch_slot,use_chests=use_chests,chest_slot=chest_slot,use_throw=use_throw,throw_slot=throw_slot}) end
	end

	local cfg = {use_torches=use_torches, torch_spacing=torch_spacing, torch_side=torch_side, torch_slot=torch_slot, use_chests=use_chests, chest_slot=chest_slot, use_throw=use_throw, throw_slot=throw_slot, auto_return=auto_return}

	term.clear(); term.setCursorPos(1,1)
	print("Entrance Carver v"..version)
	print("Width:", width, " Length:", length, " Above:", above, " Below:", below)
	print("Torches:", use_torches and ("every "..torch_spacing.." blocks on "..torch_side) or "No")
	print("Chests:", use_chests and ("slot "..chest_slot) or "No", " Throw:", use_throw and ("slot "..throw_slot) or "No")
	print("")
	print("Place torches in slot "..torch_slot..", chests in slot "..chest_slot..", sample in slot "..throw_slot.." if throwing.")
	print("")
	print("Press Enter to start..."); read()

	-- Align to left edge if starting at center
	if start_mode=="center" then local left_offset = math.floor((width-1)/2); turn_left(); for i=1,left_offset do dig_forward(); safe_forward() end; turn_right() end

	local per_slice = estimate_moves_per_slice(width, above, below)
	local depth=0; local at_left=true; local current_level=1

	for step=1,length do
		ensure_inventory_capacity(cfg, at_left)
		local reserve = per_slice + depth + 10
		if turtle.getFuelLevel()~="unlimited" and turtle.getFuelLevel()<reserve then ensure_fuel(reserve); if turtle.getFuelLevel()<reserve and cfg.auto_return then attempt_return_for_refuel(depth, reserve) end end
		at_left, current_level = carve_slice(width, above, below, at_left, current_level)
		place_torch_if_needed(step, cfg, width, at_left)
		ensure_inventory_capacity(cfg, at_left)
		-- advance to next face
		dig_forward(); safe_forward(); depth = depth + 1
	end

	term.clear(); term.setCursorPos(1,1); print("Done. Entrance completed.")
end

main()


