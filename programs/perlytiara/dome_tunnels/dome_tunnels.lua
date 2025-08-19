--[[
	Dome Tunnels by Silvamord (based on epicmining_turtle.lua style)
	Place the turtle at the bottom-left corner of the tunnel cross-section,
	facing forward (along the tunnel direction). The script will carve a dome
	profile slice-by-slice and advance.

	Parameters:
	- Width (min 2): number of blocks across (left to right)
	- Side height: height of the extreme left and right columns
	- Center height: height of the inner columns (2..width-1)
	- Length: tunnel length in blocks (number of slices)
	- Corner radius: rounds the top corners by reducing height near the sides
	  (radius 0 keeps sharp edges; radius 1+ trims the uppermost layers on sides)

	Example matching the request:
	- Width = 5
	- Side height = 3
	- Center height = 4
	- Length = your choice
	- Corner radius = 0..2 (try 1 for a slight dome rounding)
]]--

local version = "1.1"

-- UI helpers (minimal)
local function ask_number_default(prompt, default_value, min_val, max_val)
	while true do
		term.clear()
		term.setCursorPos(1,1)
		write("Dome Tunnels v"..version.."\n\n")
		write(string.format("%s [default: %s] ", prompt, tostring(default_value)))
		local s = read()
		if s == nil or s == "" then
			return default_value
		end
		local n = tonumber(s)
		if n and (not min_val or n >= min_val) and (not max_val or n <= max_val) then
			return n
		end
		write("\nInvalid input. Press Enter to try again.")
		read()
	end
end

local function ask_yes_no(prompt, default_yes)
	while true do
		term.clear()
		term.setCursorPos(1,1)
		write("Dome Tunnels v"..version.."\n\n")
		local def = default_yes and "Y" or "N"
		write(string.format("%s (y/n) [default: %s] ", prompt, def))
		local s = read()
		s = s and string.lower(s) or ""
		if s == "" then return default_yes end
		if s == "y" or s == "yes" then return true end
		if s == "n" or s == "no" then return false end
		write("\nInvalid input. Press Enter to try again.")
		read()
	end
end

local function ask_choice(prompt, default_value, choices)
	while true do
		term.clear()
		term.setCursorPos(1,1)
		write("Dome Tunnels v"..version.."\n\n")
		write(string.format("%s %s [default: %s] ", prompt, table.concat(choices, "/"), tostring(default_value)))
		local s = read()
		if s == nil or s == "" then return default_value end
		s = string.lower(s)
		for _, c in ipairs(choices) do
			if s == c then return s end
		end
		write("\nInvalid input. Press Enter to try again.")
		read()
	end
end

-- Movement helpers
local function ensure_fuel(threshold)
	if turtle.getFuelLevel() == "unlimited" then return end
	if turtle.getFuelLevel() >= threshold then return end
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel(0) then
			while turtle.getFuelLevel() < threshold and turtle.refuel(1) do end
			if turtle.getFuelLevel() >= threshold then
				return
			end
		end
	end
	term.clear()
	term.setCursorPos(1,1)
	print("Out of fuel. Put fuel in inventory and press Enter.")
	read()
	return ensure_fuel(threshold)
end

local function dig_forward()
	while turtle.detect() do
		if not turtle.dig() then
			-- try to attack entities if any
			turtle.attack()
			sleep(0.2)
		end
	end
end

local function dig_upwards()
	while turtle.detectUp() do
		if not turtle.digUp() then
			turtle.attackUp()
			sleep(0.2)
		end
	end
end

local function dig_downwards()
	while turtle.detectDown() do
		if not turtle.digDown() then
			turtle.attackDown()
			sleep(0.2)
		end
	end
end

local function safe_forward()
	ensure_fuel(100)
	while not turtle.forward() do
		dig_forward()
		-- if still blocked, wait a bit (gravel/sand falling)
		sleep(0.05)
	end
end

local function safe_up()
	ensure_fuel(100)
	while not turtle.up() do
		dig_upwards()
		sleep(0.05)
	end
end

local function safe_down()
	ensure_fuel(100)
	while not turtle.down() do
		dig_downwards()
		sleep(0.05)
	end
end

local function turn_left()
	turtle.turnLeft()
end

local function turn_right()
	turtle.turnRight()
end

-- Lateral move: step right relative to forward
local function step_right()
	turn_right()
	dig_forward()
	safe_forward()
	turn_left()
end

-- Lateral move: step left relative to forward
local function step_left()
	turn_left()
	dig_forward()
	safe_forward()
	turn_right()
end

-- Compute the effective height for a given column x (0-based from left)
local function column_height(x, width, side_h, center_h, radius)
	-- If radius == 0, use stepped profile (edges at side_h, inner at center_h)
	if (radius or 0) <= 0 then
		if x == 0 or x == width - 1 then return side_h else return center_h end
	end
	-- Rounded dome via cosine interpolation from edge (u=0) to center (u=1)
	local u
	if width <= 1 then
		u = 1
	else
		u = 1 - (math.abs(2*x - (width - 1)) / (width - 1))
	end
	-- Curvature control: larger radius -> rounder corners (faster rise near edges)
	local exponent = 1 / (1 + radius)
	local u2 = u ^ exponent
	local f = (1 - math.cos(math.pi * u2)) / 2 -- 0 at edges, 1 at center
	local h = math.floor(0.5 + (side_h + (center_h - side_h) * f))
	if h < side_h then h = side_h end
	if h > center_h then h = center_h end
	return h
end

local function compute_heights(width, side_h, center_h, radius)
	local heights = {}
	for x = 0, width - 1 do
		heights[x+1] = column_height(x, width, side_h, center_h, radius)
	end
	return heights
end

-- Carve the slice in front of the turtle for a single forward step
-- starting at bottom edge; if start_at_left is true, begin at leftmost,
-- otherwise begin at rightmost. Uses serpentine per-row to reduce moves.
-- Returns boolean: are we at left edge after finishing the slice?
local function carve_slice(width, side_h, center_h, radius, start_at_left, current_level)
	local heights = compute_heights(width, side_h, center_h, radius)
	local need_upper = false
	for i = 1, #heights do if (heights[i] or 0) >= 4 then need_upper = true break end end

	local function move_to_level(target)
		while current_level < target do safe_up(); current_level = current_level + 1 end
		while current_level > target do safe_down(); current_level = current_level - 1 end
	end

	-- Enter slice once at start, then operate mostly at level 2
	dig_forward(); safe_forward()
	if (heights[start_at_left and 1 or width] or 0) >= 2 then
		move_to_level(2)
	else
		current_level = 1
	end

	local end_at_left
	if start_at_left then
		for x = 1, width do
			local h = heights[x] or 0
			if current_level < 2 and h >= 2 then move_to_level(2) end
			if current_level > 2 and h < 3 then move_to_level(2) end
			if h >= 1 then turtle.digDown() end
			if h >= 3 then dig_upwards() end
			if x < width then step_right() end
		end
		end_at_left = false
	else
		for x = width, 1, -1 do
			local h = heights[x] or 0
			if current_level < 2 and h >= 2 then move_to_level(2) end
			if current_level > 2 and h < 3 then move_to_level(2) end
			if h >= 1 then turtle.digDown() end
			if h >= 3 then dig_upwards() end
			if x > 1 then step_left() end
		end
		end_at_left = true
	end

	-- Upper pass only if needed (h==4)
	if need_upper then
		move_to_level(3)
		if end_at_left then
			for x = 1, width do
				if (heights[x] or 0) >= 4 then dig_upwards() end
				if x < width then step_right() end
			end
			end_at_left = false
		else
			for x = width, 1, -1 do
				if (heights[x] or 0) >= 4 then dig_upwards() end
				if x > 1 then step_left() end
			end
			end_at_left = true
		end
		-- settle to level 2 to start next slice efficiently
		move_to_level(2)
	end

	return end_at_left, current_level
end

-- Estimate forward/up/down moves required to carve a slice and advance by one
local function estimate_moves_per_slice(width, side_h, center_h, radius)
	local heights = compute_heights(width, side_h, center_h, radius)
	local need_upper = false
	for i = 1, #heights do if (heights[i] or 0) >= 4 then need_upper = true break end end
	local lateral = (width - 1)
	local vertical = 1 -- adjust to level 2
	if need_upper then
		vertical = vertical + 2 -- up to level 3 and back to 2
		lateral = lateral + (width - 1)
	end
	local advance = 1 -- entering slice
	return vertical + lateral + advance
end

local function turn_around()
	turn_right(); turn_right()
end

local function move_forward_n(n)
	for i = 1, n do
		-- path should be clear; still be safe
		safe_forward()
	end
end

local function ensure_fuel_or_prompt(threshold)
	ensure_fuel(threshold)
	if turtle.getFuelLevel() == "unlimited" then return end
	if turtle.getFuelLevel() >= threshold then return end
	term.clear()
	term.setCursorPos(1,1)
	print("Fuel still low. Put fuel in inventory and press Enter.")
	read()
	ensure_fuel(threshold)
end

local function attempt_return_for_refuel(depth, reserve_needed)
	-- Ensure we can get back to start and forth again
	local minimal = depth * 2 + 4
	if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < minimal then
		ensure_fuel_or_prompt(minimal)
	end
	turn_around()
	move_forward_n(depth)
	term.clear(); term.setCursorPos(1,1)
	print("At start. Add fuel now, then press Enter to resume.")
	read()
	ensure_fuel_or_prompt(reserve_needed)
	turn_around()
	move_forward_n(depth)
end

-- Favorites storage helpers
local function favorite_path()
	local dir = ".dome_tunnels"
	if not fs.exists(dir) then fs.makeDir(dir) end
	return fs.combine(dir, "dome_tunnel_favorite")
end

local function load_favorite()
	local path = favorite_path()
	-- Backward compatibility: migrate old root-level file if present
	if not fs.exists(path) and fs.exists("dome_favorite") then
		local hOld = fs.open("dome_favorite", "r")
		if hOld then
			local d = hOld.readAll(); hOld.close()
			local okOld, tblOld = pcall(textutils.unserialize, d)
			if okOld and type(tblOld) == "table" then
				local hNew = fs.open(path, "w")
				if hNew then hNew.write(textutils.serialize(tblOld)); hNew.close() end
				-- Optionally remove old file
				pcall(fs.delete, "dome_favorite")
			end
		end
	end
	if not fs.exists(path) then return nil end
	local h = fs.open(path, "r")
	if not h then return nil end
	local data = h.readAll()
	h.close()
	local ok, tbl = pcall(textutils.unserialize, data)
	if ok and type(tbl) == "table" then return tbl end
	return nil
end

local function save_favorite(fav)
	local path = favorite_path()
	local h = fs.open(path, "w")
	if not h then return end
	h.write(textutils.serialize(fav))
	h.close()
end

-- Inventory helpers
local function count_empty_slots()
	local empty = 0
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then empty = empty + 1 end
	end
	return empty
end

local function any_item_matches_slot(slot_idx)
	if turtle.getItemCount(slot_idx) == 0 then return false end
	for i = 1, 16 do
		if i ~= slot_idx and turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if turtle.compareTo(slot_idx) then return true end
		end
	end
	return false
end

local function drop_matching_front(slot_idx)
	for i = 1, 16 do
		if i ~= slot_idx and turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if turtle.compareTo(slot_idx) then
				turtle.drop()
			end
		end
	end
end

local function turn_to_side(side)
	if side == "left" then turn_left() else turn_right() end
end

local function place_chest_in_wall(chest_slot, side)
	if turtle.getItemCount(chest_slot) == 0 then return false end
	turn_to_side(side)
	dig_forward()
	turtle.select(chest_slot)
	local ok = turtle.place()
	if not ok then
		-- try clearing again and placing
		dig_forward()
		ok = turtle.place()
	end
	if not ok then
		-- fallback: place below
		ok = turtle.placeDown()
	end
	if not ok then
		-- failed to place; face forward again
		turn_to_side(side == "left" and "right" or "left")
		return false
	end
	-- face back forward
	turn_to_side(side == "left" and "right" or "left")
	return true
end

local function deposit_into_front(chest_slot, torch_slot, throw_slot)
	for i = 1, 16 do
		if i ~= chest_slot and i ~= torch_slot and i ~= throw_slot and turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if turtle.refuel(0) then
				-- skip fuel
			else
				turtle.drop()
			end
		end
	end
	-- handle throw slot: keep one
	if throw_slot and throw_slot >= 1 and throw_slot <= 16 then
		local cnt = turtle.getItemCount(throw_slot)
		if cnt > 1 then
			turtle.select(throw_slot)
			turtle.drop(cnt - 1)
		end
	end
end

local function ensure_inventory_capacity(cfg, at_left_edge)
	local empty = count_empty_slots()
	if empty > 0 then return end
	if cfg.use_throw and turtle.getItemCount(cfg.throw_slot) > 0 and any_item_matches_slot(cfg.throw_slot) then
		drop_matching_front(cfg.throw_slot)
		if count_empty_slots() > 0 then return end
	end
	if cfg.use_chests then
		local side = at_left_edge and "left" or "right"
		if place_chest_in_wall(cfg.chest_slot, side) then
			deposit_into_front(cfg.chest_slot, cfg.torch_slot, cfg.throw_slot)
		end
	end
end

local function place_torch_if_needed(step_idx, cfg, width, side_h, center_h, radius, at_left_edge)
	if not cfg.use_torches then return end
	if cfg.torch_spacing <= 0 then return end
	if step_idx % cfg.torch_spacing ~= 0 then return end
	if turtle.getItemCount(cfg.torch_slot) == 0 then return end
	local function place_on_side(side)
		local heights = compute_heights(width, side_h, center_h, radius)
		local h_edge = heights[(side == "left") and 1 or width] or 1
		local climbed = 0
		if h_edge >= 2 then
			safe_up()
			climbed = climbed + 1
		end
		turn_to_side(side)
		turtle.select(cfg.torch_slot)
		local ok = turtle.place()
		if not ok then
			-- fallback to floor torch
			turn_to_side(side == "left" and "right" or "left")
			for i = 1, climbed do safe_down() end
			turtle.select(cfg.torch_slot)
			ok = turtle.placeDown()
			return
		end
		turn_to_side(side == "left" and "right" or "left")
		for i = 1, climbed do safe_down() end
	end

	if cfg.torch_side == "both" then
		-- Place on both sides, starting with the current edge for efficiency
		if at_left_edge then
			place_on_side("left")
			place_on_side("right")
		else
			place_on_side("right")
			place_on_side("left")
		end
	else
		-- Single side: honor user's side; if set to left/right, use that side
		place_on_side(cfg.torch_side)
	end
end

-- Main
local function main()
	term.clear()
	term.setCursorPos(1,1)
	print("Dome Tunnels v"..version)
	print("Place turtle at bottom-left corner, facing forward.")

	local fav = load_favorite()
	local use_fav = false
	if fav then
		use_fav = ask_yes_no("Use favorite saved config?", true)
	end

	local width, side_h, center_h, length, radius, auto_return
	local use_torches, torch_spacing, torch_side, torch_slot
	local use_chests, chest_slot
	local use_throw, throw_slot

	if use_fav then
		width = fav.width; side_h = fav.side_h; center_h = fav.center_h; length = fav.length; radius = fav.radius
		auto_return = fav.auto_return
		use_torches = fav.use_torches; torch_spacing = fav.torch_spacing or 9; torch_side = fav.torch_side or "right"; torch_slot = fav.torch_slot or 1
		use_chests = fav.use_chests; chest_slot = fav.chest_slot or 2
		use_throw = fav.use_throw; throw_slot = fav.throw_slot or 4
	else
		-- Defaults tailored to the requested shape: 5-wide, sides 3 high, center 4 high
		width = ask_number_default("Width (min 2):", 5, 2, 64)
		side_h = ask_number_default("Side height (>=1):", 3, 1, 64)
		center_h = ask_number_default("Center height (>=1):", 4, 1, 64)
		length = ask_number_default("Length (>=1):", 32, 1, 100000)
		radius = ask_number_default("Corner radius (0 = stepped, higher = rounder):", 0, 0, 32)
		auto_return = ask_yes_no("Auto-return to start to refuel when needed?", true)
		use_torches = ask_yes_no("Place torches?", true)
		if use_torches then
			torch_spacing = ask_number_default("Torch spacing (blocks):", 9, 1, 64)
			torch_side = ask_choice("Torch side:", "both", {"left", "right", "both"})
			torch_slot = ask_number_default("Torch slot (1-16):", 1, 1, 16)
		else
			torch_spacing = 0; torch_side = "right"; torch_slot = 1
		end
		use_chests = ask_yes_no("Place chests to dump items when full?", true)
		if use_chests then
			chest_slot = ask_number_default("Chest slot (1-16):", 2, 1, 16)
		else
			chest_slot = 2
		end
		use_throw = ask_yes_no("Throw items matching a sample when full?", false)
		if use_throw then
			throw_slot = ask_number_default("Sample slot to throw (1-16):", 4, 1, 16)
		else
			throw_slot = 4
		end
		local savefav = ask_yes_no("Save these settings as favorite?", true)
		if savefav then
			local tosave = {
				width = width, side_h = side_h, center_h = center_h, length = length, radius = radius,
				auto_return = auto_return,
				use_torches = use_torches, torch_spacing = torch_spacing, torch_side = torch_side, torch_slot = torch_slot,
				use_chests = use_chests, chest_slot = chest_slot,
				use_throw = use_throw, throw_slot = throw_slot
			}
			save_favorite(tosave)
		end
	end

	local cfg = {
		use_torches = use_torches, torch_spacing = torch_spacing, torch_side = torch_side, torch_slot = torch_slot,
		use_chests = use_chests, chest_slot = chest_slot,
		use_throw = use_throw, throw_slot = throw_slot,
		auto_return = auto_return
	}

	term.clear()
	term.setCursorPos(1,1)
	print("Dome Tunnels v"..version)
	print("Width:\t\t"..width)
	print("Side height:\t"..side_h)
	print("Center height:\t"..center_h)
	print("Length:\t\t"..length)
	print("Corner radius:\t"..radius)
	print("Auto-return for fuel:\t"..(auto_return and "Yes" or "No"))
	print("Torches:\t\t"..(cfg.use_torches and ("Yes (every "..cfg.torch_spacing.." blocks)") or "No"))
	if cfg.use_torches then
		print("Torch side:\t"..cfg.torch_side.." (top corners; no extra wall digging)")
		print("Torch slot:\t"..cfg.torch_slot)
	end
	print("Chests:\t\t"..(cfg.use_chests and ("Yes (slot "..cfg.chest_slot..")") or "No"))
	print("Throw items:\t"..(cfg.use_throw and ("Yes (sample slot "..cfg.throw_slot..")") or "No"))
	print("")
	print("Put torches in slot "..cfg.torch_slot..", chests in slot "..cfg.chest_slot..", sample item in slot "..cfg.throw_slot.." if throwing is enabled.")
	print("")
	print("Press Enter to start...")
	read()

	local per_slice_moves = estimate_moves_per_slice(width, side_h, center_h, radius)
	local depth = 0
	local at_left_edge = true -- start at bottom-left by convention
	local current_level = 1

	-- Carve tunnel
	for step = 1, length do
		ensure_inventory_capacity(cfg, at_left_edge)
		-- Fuel check: we want enough for this slice plus the trip back to start
		local reserve_needed = per_slice_moves + depth + 10
		if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < reserve_needed then
			ensure_fuel_or_prompt(reserve_needed)
			if turtle.getFuelLevel() < reserve_needed and cfg.auto_return then
				attempt_return_for_refuel(depth, reserve_needed)
			end
		end

		at_left_edge, current_level = carve_slice(width, side_h, center_h, radius, at_left_edge, current_level)
		place_torch_if_needed(step, cfg, width, side_h, center_h, radius, at_left_edge)
		ensure_inventory_capacity(cfg, at_left_edge)
		depth = depth + 1
	end

	term.clear()
	term.setCursorPos(1,1)
	print("Done. Dome tunnel completed.")
end

main()


