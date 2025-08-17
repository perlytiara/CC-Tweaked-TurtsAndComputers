--[[
	Room Carver by Silvamord
	Place the turtle at the doorway bottom-left (or center -> shift left) facing the room direction.
	Carves a rectangular room of width x depth with height split: above floor and below floor.
]]--

local version = "0.1"

-- Import minimal helpers from entrance_carver pattern (duplicated for standalone use)
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

local function ask_choice(prompt, default_value, choices)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Room Carver v"..version.."\n\n")
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
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel(0) then while turtle.getFuelLevel() < threshold and turtle.refuel(1) do end; if turtle.getFuelLevel() >= threshold then return end end
	end
	term.clear(); term.setCursorPos(1,1); print("Out of fuel. Put fuel in inventory and press Enter."); read(); return ensure_fuel(threshold)
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

-- Torch/chest/throw (lean)
local function count_empty_slots() local e=0; for i=1,16 do if turtle.getItemCount(i)==0 then e=e+1 end end return e end
local function any_item_matches_slot(slot_idx) if turtle.getItemCount(slot_idx)==0 then return false end for i=1,16 do if i~=slot_idx and turtle.getItemCount(i)>0 then turtle.select(i); if turtle.compareTo(slot_idx) then return true end end end return false end
local function drop_matching_front(slot_idx) for i=1,16 do if i~=slot_idx and turtle.getItemCount(i)>0 then turtle.select(i); if turtle.compareTo(slot_idx) then turtle.drop() end end end end
local function turn_to_side(side) if side=="left" then turn_left() else turn_right() end end
local function place_chest_in_wall(chest_slot, side) if turtle.getItemCount(chest_slot)==0 then return false end; turn_to_side(side); dig_forward(); turtle.select(chest_slot); local ok=turtle.place(); if not ok then dig_forward(); ok=turtle.place() end; if not ok then ok=turtle.placeDown() end; turn_to_side(side=="left" and "right" or "left"); return ok end
local function deposit_into_front(chest_slot, torch_slot, throw_slot) for i=1,16 do if i~=chest_slot and i~=torch_slot and i~=throw_slot and turtle.getItemCount(i)>0 then turtle.select(i); if not turtle.refuel(0) then turtle.drop() end end end; if throw_slot and throw_slot>=1 and throw_slot<=16 then local cnt=turtle.getItemCount(throw_slot); if cnt>1 then turtle.select(throw_slot); turtle.drop(cnt-1) end end end
local function ensure_inventory_capacity(cfg, at_left_edge) if count_empty_slots()>0 then return end; if cfg.use_throw and turtle.getItemCount(cfg.throw_slot)>0 and any_item_matches_slot(cfg.throw_slot) then drop_matching_front(cfg.throw_slot); if count_empty_slots()>0 then return end end; if cfg.use_chests then local side=at_left_edge and "left" or "right"; if place_chest_in_wall(cfg.chest_slot, side) then deposit_into_front(cfg.chest_slot, cfg.torch_slot, cfg.throw_slot) end end end

local function place_torch_if_needed(step_idx, cfg, room_w, at_left_edge)
	if not cfg.use_torches or cfg.torch_spacing<=0 then return end
	if step_idx % cfg.torch_spacing ~= 0 then return end
	if turtle.getItemCount(cfg.torch_slot)==0 then return end
	local function place_on_side(side)
		turn_to_side(side); turtle.select(cfg.torch_slot); local ok=turtle.place(); if not ok then turn_to_side(side=="left" and "right" or "left"); turtle.select(cfg.torch_slot); turtle.placeDown(); return end; turn_to_side(side=="left" and "right" or "left")
	end
	if cfg.torch_side=="both" then if at_left_edge then place_on_side("left"); place_on_side("right") else place_on_side("right"); place_on_side("left") end else place_on_side(cfg.torch_side) end
end

-- Carve room rectangle using level-2 reach for floor+above, then below floor
local function carve_room_rect(room_w, room_d, above, below, at_left_edge)
	-- Phase A: level 2 reach if possible
	local work_level = (above >= 2) and 2 or 1
	if work_level == 2 then safe_up() end
	local left_to_right = at_left_edge
	for z=1, room_d do
		if left_to_right then
			for x=1, room_w do if work_level==1 then dig_forward() else turtle.digDown(); if above>=2 then dig_upwards() end end; if x<room_w then step_right() end end
		else
			for x=room_w,1,-1 do if work_level==1 then dig_forward() else turtle.digDown(); if above>=2 then dig_upwards() end end; if x>1 then step_left() end end
		end
		left_to_right = not left_to_right
		if z<room_d then dig_forward(); safe_forward() end
	end
	-- Extra top pass when above >= 3
	if above>=3 then
		safe_up(); left_to_right = not left_to_right -- keep edge alternation
		for z=1, room_d do
			if left_to_right then for x=1,room_w do dig_upwards(); if x<room_w then step_right() end end else for x=room_w,1,-1 do dig_upwards(); if x>1 then step_left() end end end
			left_to_right = not left_to_right; if z<room_d then dig_forward(); safe_forward() end
		end
		safe_down()
	end
	-- Phase B: below floor
	if below>=1 then if work_level==2 then safe_down() end; left_to_right = not left_to_right; for z=1,room_d do if left_to_right then for x=1,room_w do turtle.digDown(); if x<room_w then step_right() end end else for x=room_w,1,-1 do turtle.digDown(); if x>1 then step_left() end end end; left_to_right = not left_to_right; if z<room_d then dig_forward(); safe_forward() end end end
	return left_to_right -- indicates edge for torch/chest side
end

local function main()
	term.clear(); term.setCursorPos(1,1)
	print("Room Carver v"..version)
	print("Place turtle facing the room direction.")

	local fav=nil
	local use_fav=false

	local start_mode = ask_choice("Start at:", "center", {"center","bottom-left"})
	local room_w = ask_number_default("Room width (X):", 9, 1, 199)
	local room_d = ask_number_default("Room depth (Z):", 9, 1, 199)
	local above = ask_number_default("Height above floor:", 3, 0, 32)
	local below = ask_number_default("Height below floor:", 0, 0, 16)
	local use_torches = ask_yes_no("Place torches?", true)
	local torch_spacing, torch_side, torch_slot
	if use_torches then torch_spacing = ask_number_default("Torch spacing (blocks):", 9, 1, 64); torch_side = ask_choice("Torch side:", "both", {"left","right","both"}); torch_slot = ask_number_default("Torch slot (1-16):", 1, 1, 16) else torch_spacing=0; torch_side="right"; torch_slot=1 end
	local use_chests = ask_yes_no("Place chests to dump items when full?", true); local chest_slot = use_chests and ask_number_default("Chest slot (1-16):", 2, 1, 16) or 2
	local use_throw = ask_yes_no("Throw items matching a sample when full?", false); local throw_slot = use_throw and ask_number_default("Sample slot to throw (1-16):", 4, 1, 16) or 4

	term.clear(); term.setCursorPos(1,1)
	print("Room:"..room_w.."w x "..room_d.."d, +"..above.."/-"..below.."; torches:"..(use_torches and ("every "..torch_spacing) or "no"))
	print(""); print("Press Enter to start..."); read()

	-- Align to bottom-left if starting at center
	if start_mode=="center" then local left_offset = math.floor((room_w-1)/2); turn_left(); for i=1,left_offset do dig_forward(); safe_forward() end; turn_right() end

	local at_left_edge = true
	local cfg = {use_torches=use_torches, torch_spacing=torch_spacing, torch_side=torch_side, torch_slot=torch_slot, use_chests=use_chests, chest_slot=chest_slot, use_throw=use_throw, throw_slot=throw_slot}
	carve_room_rect(room_w, room_d, above, below, at_left_edge)
	place_torch_if_needed(1, cfg, room_w, at_left_edge)

	term.clear(); term.setCursorPos(1,1); print("Done. Room completed.")
end

main()


