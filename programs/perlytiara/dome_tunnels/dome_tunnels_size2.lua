--[[
	Dome Tunnels (Size2) by Silvamord
	Fixed cross-section: 7 blocks wide
	- Columns 1-2: height 3
	- Columns 3-5: height 4
	- Columns 6-7: height 3

	Place the turtle at the bottom-left corner of the tunnel cross-section,
	facing forward along the tunnel direction. The script carves one slice per
	forward step using a serpentine pattern for efficiency.

	Prompts:
	- Length (number of slices forward)
	- Optional torches (spacing, side, slot)
]]--

local version = "1.0"

-- Fixed profile for width 7: 3,3,4,4,4,3,3
local WIDTH = 7
local FIXED_HEIGHTS = {3,3,4,4,4,3,3}

-- UI helpers (minimal)
local function ask_number_default(prompt, default_value, min_val, max_val)
	while true do
		term.clear()
		term.setCursorPos(1,1)
		write("Dome Tunnels Size2 v"..version.."\n\n")
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
		write("Dome Tunnels Size2 v"..version.."\n\n")
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
		write("Dome Tunnels Size2 v"..version.."\n\n")
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

local function step_right()
	turn_right()
	dig_forward()
	safe_forward()
	turn_left()
end

local function step_left()
	turn_left()
	dig_forward()
	safe_forward()
	turn_right()
end

-- Carve the slice in front of the turtle for a single forward step
-- starting at bottom edge; if start_at_left is true, begin at leftmost,
-- otherwise begin at rightmost. Uses serpentine per-row to reduce moves.
-- Returns boolean: are we at left edge after finishing the slice? and current level.
local function carve_slice_fixed(start_at_left, current_level)
	local heights = FIXED_HEIGHTS
	local need_upper = true -- fixed pattern includes height 4 columns

	local function move_to_level(target)
		while current_level < target do safe_up(); current_level = current_level + 1 end
		while current_level > target do safe_down(); current_level = current_level - 1 end
	end

	-- Enter slice once at start, then operate mostly at level 2
	dig_forward(); safe_forward()
	if (heights[start_at_left and 1 or WIDTH] or 0) >= 2 then
		move_to_level(2)
	else
		current_level = 1
	end

	local end_at_left
	if start_at_left then
		for x = 1, WIDTH do
			local h = heights[x] or 0
			if current_level < 2 and h >= 2 then move_to_level(2) end
			if current_level > 2 and h < 3 then move_to_level(2) end
			if h >= 1 then turtle.digDown() end
			if h >= 3 then dig_upwards() end
			if x < WIDTH then step_right() end
		end
		end_at_left = false
	else
		for x = WIDTH, 1, -1 do
			local h = heights[x] or 0
			if current_level < 2 and h >= 2 then move_to_level(2) end
			if current_level > 2 and h < 3 then move_to_level(2) end
			if h >= 1 then turtle.digDown() end
			if h >= 3 then dig_upwards() end
			if x > 1 then step_left() end
		end
		end_at_left = true
	end

	-- Upper pass only for the 4-high columns
	if need_upper then
		move_to_level(3)
		if end_at_left then
			for x = 1, WIDTH do
				if (heights[x] or 0) >= 4 then dig_upwards() end
				if x < WIDTH then step_right() end
			end
			end_at_left = false
		else
			for x = WIDTH, 1, -1 do
				if (heights[x] or 0) >= 4 then dig_upwards() end
				if x > 1 then step_left() end
			end
			end_at_left = true
		end
		move_to_level(2)
	end

	return end_at_left, current_level
end

-- Estimate moves per slice for fueling
local function estimate_moves_per_slice_fixed()
	local lateral = (WIDTH - 1)
	local vertical = 1 -- adjust to level 2
	local need_upper = true
	if need_upper then
		vertical = vertical + 2 -- up to level 3 and back to 2
		lateral = lateral + (WIDTH - 1)
	end
	local advance = 1 -- entering slice
	return vertical + lateral + advance
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

-- Inventory helpers (minimal)
local function count_empty_slots()
	local empty = 0
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then empty = empty + 1 end
	end
	return empty
end

local function ensure_inventory_capacity()
	if count_empty_slots() > 0 then return end
	term.clear()
	term.setCursorPos(1,1)
	print("Inventory full. Empty some slots and press Enter to continue.")
	read()
end

local function turn_to_side(side)
	if side == "left" then turn_left() else turn_right() end
end

local function place_torch_if_needed(step_idx, cfg, at_left_edge)
	if not cfg.use_torches then return end
	if cfg.torch_spacing <= 0 then return end
	if step_idx % cfg.torch_spacing ~= 0 then return end
	if turtle.getItemCount(cfg.torch_slot) == 0 then return end

	local function place_on_side(side)
		local h_edge = (side == "left") and FIXED_HEIGHTS[1] or FIXED_HEIGHTS[WIDTH]
		local climbed = 0
		if h_edge >= 2 then
			safe_up()
			climbed = climbed + 1
		end
		turn_to_side(side)
		turtle.select(cfg.torch_slot)
		local ok = turtle.place()
		if not ok then
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
		if at_left_edge then
			place_on_side("left")
			place_on_side("right")
		else
			place_on_side("right")
			place_on_side("left")
		end
	else
		place_on_side(cfg.torch_side)
	end
end

-- Main
local function main()
	term.clear()
	term.setCursorPos(1,1)
	print("Dome Tunnels Size2 v"..version)
	print("Fixed profile: [3,3,4,4,4,3,3] (width 7)")
	print("Place turtle at bottom-left corner, facing forward.")

	local length = ask_number_default("Length (>=1):", 32, 1, 100000)
	local use_torches = ask_yes_no("Place torches?", true)
	local torch_spacing, torch_side, torch_slot
	if use_torches then
		torch_spacing = ask_number_default("Torch spacing (blocks):", 9, 1, 64)
		torch_side = ask_choice("Torch side:", "both", {"left", "right", "both"})
		torch_slot = ask_number_default("Torch slot (1-16):", 1, 1, 16)
	else
		torch_spacing = 0; torch_side = "right"; torch_slot = 1
	end

	local cfg = {
		use_torches = use_torches,
		torch_spacing = torch_spacing,
		torch_side = torch_side,
		torch_slot = torch_slot
	}

	term.clear()
	term.setCursorPos(1,1)
	print("Dome Tunnels Size2 v"..version)
	print("Width:\t\t"..WIDTH)
	print("Heights:\t\t[3,3,4,4,4,3,3]")
	print("Length:\t\t"..length)
	print("Torches:\t\t"..(cfg.use_torches and ("Yes (every "..cfg.torch_spacing.." blocks)") or "No"))
	if cfg.use_torches then
		print("Torch side:\t"..cfg.torch_side)
		print("Torch slot:\t"..cfg.torch_slot)
	end
	print("")
	print("Press Enter to start...")
	read()

	local per_slice_moves = estimate_moves_per_slice_fixed()
	local depth = 0
	local at_left_edge = true -- start at bottom-left by convention
	local current_level = 1

	for step = 1, length do
		ensure_inventory_capacity()
		local reserve_needed = per_slice_moves + depth + 10
		if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < reserve_needed then
			ensure_fuel_or_prompt(reserve_needed)
		end

		at_left_edge, current_level = carve_slice_fixed(at_left_edge, current_level)
		place_torch_if_needed(step, cfg, at_left_edge)
		ensure_inventory_capacity()
		depth = depth + 1
	end

	term.clear()
	term.setCursorPos(1,1)
	print("Done. 7-wide dome tunnel completed.")
end

main()


