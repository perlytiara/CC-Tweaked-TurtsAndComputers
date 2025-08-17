--[[
	Dig Enter Room by Silvamord
	Place turtle in the tunnel, facing a wall at the entrance.
	Start mode options:
	- center: turtle is at the center column of the doorway
	- bottom-left: turtle is at the bottom-left corner of the doorway

	Flow:
	- Move forward by doorway length
	- Reposition to bottom-left corner of room bounding box at floor level
	- Carve the room volume centered on the doorway centerline
	- Optional: build floors at multiple levels
]]--

local version = "0.1"

-- UI helpers
local function ask_number_default(prompt, default_value, min_val, max_val)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Dig Enter Room v"..version.."\n\n")
		write(string.format("%s [default: %s] ", prompt, tostring(default_value)))
		local s = read()
		if s == nil or s == "" then return default_value end
		local n = tonumber(s)
		if n and (not min_val or n >= min_val) and (not max_val or n <= max_val) then return n end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end

local function ask_yes_no(prompt, default_yes)
	while true do
		term.clear(); term.setCursorPos(1,1)
		write("Dig Enter Room v"..version.."\n\n")
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
		write("Dig Enter Room v"..version.."\n\n")
		write(string.format("%s %s [default: %s] ", prompt, table.concat(choices, "/"), tostring(default_value)))
		local s = read(); if s == nil or s == "" then return default_value end
		s = string.lower(s)
		for _, c in ipairs(choices) do if s == c then return s end end
		write("\nInvalid input. Press Enter to try again."); read()
	end
end

-- Movement helpers (copied minimal set from dome_tunnels)
local function ensure_fuel(threshold)
	if turtle.getFuelLevel() == "unlimited" then return end
	if turtle.getFuelLevel() >= threshold then return end
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel(0) then
			while turtle.getFuelLevel() < threshold and turtle.refuel(1) do end
			if turtle.getFuelLevel() >= threshold then return end
		end
	end
	term.clear(); term.setCursorPos(1,1)
	print("Out of fuel. Put fuel in inventory and press Enter."); read()
	return ensure_fuel(threshold)
end

local function dig_forward()
	while turtle.detect() do if not turtle.dig() then turtle.attack(); sleep(0.1) end end
end
local function dig_upwards()
	while turtle.detectUp() do if not turtle.digUp() then turtle.attackUp(); sleep(0.1) end end
end
local function dig_downwards()
	while turtle.detectDown() do if not turtle.digDown() then turtle.attackDown(); sleep(0.1) end end
end

local function safe_forward()
	ensure_fuel(100)
	while not turtle.forward() do dig_forward(); sleep(0.05) end
end
local function safe_up()
	ensure_fuel(100)
	while not turtle.up() do dig_upwards(); sleep(0.05) end
end
local function safe_down()
	ensure_fuel(100)
	while not turtle.down() do dig_downwards(); sleep(0.05) end
end

local function turn_left() turtle.turnLeft() end
local function turn_right() turtle.turnRight() end
local function step_right() turn_right(); dig_forward(); safe_forward(); turn_left() end
local function step_left() turn_left(); dig_forward(); safe_forward(); turn_right() end

-- Inventory helpers (lean version)
local function count_empty_slots()
	local empty = 0; for i=1,16 do if turtle.getItemCount(i)==0 then empty=empty+1 end end; return empty
end
local function ensure_inventory_capacity()
	if count_empty_slots()>0 then return end
	-- Basic: try to drop in front if chest present in slot 2
	local chest_slot = 2
	if turtle.getItemCount(chest_slot)>0 then
		turn_right(); dig_forward(); turtle.select(chest_slot); if turtle.place() then
			for i=1,16 do if i~=chest_slot and turtle.getItemCount(i)>0 then turtle.select(i); turtle.drop() end end
		end
		turn_left()
	end
end

-- Favorites storage
local function favorite_path()
	local dir = ".enter_room"; if not fs.exists(dir) then fs.makeDir(dir) end
	return fs.combine(dir, "dig_enter_room_favorite")
end
local function load_favorite()
	local p = favorite_path(); if not fs.exists(p) then return nil end
	local h = fs.open(p, "r"); if not h then return nil end; local d=h.readAll(); h.close()
	local ok,t = pcall(textutils.unserialize,d); if ok and type(t)=="table" then return t end; return nil
end
local function save_favorite(tbl)
	local p = favorite_path(); local h = fs.open(p,"w"); if not h then return end; h.write(textutils.serialize(tbl)); h.close()
end

-- Shape mask helpers
local function in_square(x, z, width, depth)
	return x>=1 and x<=width and z>=1 and z<=depth
end
local function in_circle(x, z, width, depth)
	-- circle inscribed in rectangle width x depth centered
	local cx = (width+1)/2; local cz = (depth+1)/2
	local rx = width/2; local rz = depth/2
	local dx = (x - cx)/rx; local dz = (z - cz)/rz
	return (dx*dx + dz*dz) <= 1.0
end
local function in_triangle(x, z, width, depth)
	-- isosceles triangle with base at z=1 spanning width, apex at z=depth center
	if z<1 or z>depth then return false end
	local half = (width-1)/2
	local max_half_at_z = math.max(0, half * (1 - (z-1)/(depth-1)))
	local cx = (width+1)/2
	return math.abs(x - cx) <= max_half_at_z + 0.0001
end

local function make_mask(shape, width, depth)
	local mask = {}
	for z=1,depth do
		mask[z] = {}
		for x=1,width do
			local inside = false
			if shape=="square" then inside = in_square(x,z,width,depth)
			elseif shape=="circle" then inside = in_circle(x,z,width,depth)
			elseif shape=="triangle" then inside = in_triangle(x,z,width,depth)
			end
			mask[z][x] = inside
		end
	end
	return mask
end

-- Carve rectangular doorway face of given width/height at current position; return whether we end at left
local function carve_rect_face(doorway_w, doorway_h, start_at_left)
	local max_h = doorway_h
	local left_to_right = start_at_left
	for row = 1, max_h do
		if row > 1 then safe_up() end
		if left_to_right then
			for x = 1, doorway_w do
				dig_forward()
				if x < doorway_w then step_right() end
			end
		else
			for x = doorway_w, 1, -1 do
				dig_forward()
				if x > 1 then step_left() end
			end
		end
		left_to_right = not left_to_right
	end
	for row = max_h, 2, -1 do safe_down() end
	local end_at_left = start_at_left
	if (max_h % 2) == 1 then end_at_left = not start_at_left end
	return end_at_left
end

-- Carve room: starting at bottom-left corner at floor level, facing forward
local function carve_room(shape, room_w, room_d, above, below)
	local mask = make_mask(shape, room_w, room_d)
	-- y loop: from floor-below to floor+above
	for y = -below, above do
		-- move to target y
		if y > 0 then for _=1,y do safe_up() end elseif y < 0 then for _=1,-y do safe_down() end end
		local left_to_right = true
		for z=1, room_d do
			if left_to_right then
				for x=1, room_w do
					if mask[z][x] then dig_forward() end
					if x < room_w then step_right() end
				end
			else
				for x=room_w,1,-1 do
					if mask[z][x] then dig_forward() end
					if x > 1 then step_left() end
				end
			end
			left_to_right = not left_to_right
			if z < room_d then dig_forward(); safe_forward() end
		end
		-- return to floor level before next y
		if y > 0 then for _=1,y do safe_down() end elseif y < 0 then for _=1,-y do safe_up() end end
	end
end

local function main()
	term.clear(); term.setCursorPos(1,1)
	print("Dig Enter Room v"..version)
	print("Place turtle facing the wall at the doorway.")

	local fav = load_favorite(); local use_fav = fav and ask_yes_no("Use favorite saved config?", true) or false

	local start_mode, doorway_w, doorway_len, doorway_h
	local shape, room_w, room_d, above, below
	local multi_levels, num_levels, level_spacing, build_floors, floor_slot

	if use_fav then
		start_mode = fav.start_mode or "center"
		doorway_w = fav.doorway_w or 5
		doorway_len = fav.doorway_len or 5
		shape = fav.shape or "square"
		room_w = fav.room_w or 9
		room_d = fav.room_d or 9
		above = fav.above or 3
		below = fav.below or 0
		multi_levels = fav.multi_levels or false
		num_levels = fav.num_levels or 1
		level_spacing = fav.level_spacing or 4
		build_floors = fav.build_floors or false
		floor_slot = fav.floor_slot or 3
	else
		start_mode = ask_choice("Start mode:", "center", {"center","bottom-left"})
		doorway_w = ask_number_default("Doorway width:", 5, 1, 99)
		doorway_len = ask_number_default("Doorway length (forward):", 5, 0, 1000)
		shape = ask_choice("Room shape:", "square", {"square","circle","triangle"})
		if shape == "square" then
			room_w = ask_number_default("Room width (X):", 9, 1, 199)
			room_d = ask_number_default("Room depth (Z):", 9, 1, 199)
		elseif shape == "circle" then
			local unit = ask_choice("Circle size unit:", "radius", {"radius","diameter"})
			if unit == "radius" then
				local r = ask_number_default("Radius:", 5, 1, 99); room_w = 2*r+1; room_d = 2*r+1
			else
				local d = ask_number_default("Diameter:", 11, 3, 199); room_w = d; room_d = d
			end
		else
			room_w = ask_number_default("Triangle base width (X):", 9, 3, 199)
			room_d = ask_number_default("Triangle depth (Z):", 9, 2, 199)
		end
		doorway_h = ask_number_default("Doorway height above floor:", 3, 1, 16)
		above = ask_number_default("Height above floor:", 3, 0, 32)
		below = ask_number_default("Height below floor:", 0, 0, 16)
		multi_levels = ask_yes_no("Multiple levels?", false)
		if multi_levels then
			num_levels = ask_number_default("Number of levels:", 2, 2, 10)
			level_spacing = ask_number_default("Level spacing (vertical):", 4, 2, 32)
			build_floors = ask_yes_no("Build floors at each level?", true)
			if build_floors then floor_slot = ask_number_default("Floor block slot (1-16):", 3, 1, 16) else floor_slot = 3 end
		else
			num_levels = 1; level_spacing = 0; build_floors = false; floor_slot = 3
		end
		if ask_yes_no("Save as favorite?", true) then
			save_favorite({start_mode=start_mode, doorway_w=doorway_w, doorway_len=doorway_len, shape=shape, room_w=room_w, room_d=room_d, above=above, below=below, multi_levels=multi_levels, num_levels=num_levels, level_spacing=level_spacing, build_floors=build_floors, floor_slot=floor_slot})
		end
	end

	term.clear(); term.setCursorPos(1,1)
	print("Start:"..start_mode.."  Doorway:"..doorway_w.."w x "..doorway_len.."l x "..(doorway_h or 3).."h  Shape:"..shape)
	print("Room:"..room_w.."w x "..room_d.."d  Height:+"..above.."/-"..below)
	if multi_levels then print("Levels:"..num_levels.." every "..level_spacing.."; build floors:"..tostring(build_floors)) end
	print(""); print("Press Enter to start..."); read()

	-- Step 1: align to bottom-left corner of doorway
	local left_offset = math.floor((doorway_w-1)/2)
	if start_mode == "center" then turn_left(); for i=1,left_offset do dig_forward(); safe_forward() end; turn_right() end

	-- Step 2: carve doorway (width x height x length), serpentine per face
	local at_left = true
	for slice=1, doorway_len do
		at_left = carve_rect_face(doorway_w, doorway_h or 3, at_left)
		-- advance into carved slice
		dig_forward(); safe_forward()
	end
	-- Ensure at leftmost edge at floor for room start
	if not at_left then for i=1, (doorway_w-1) do step_left() end end

	-- Carve levels
	for level=1, num_levels do
		carve_room(shape, room_w, room_d, above, below)
		-- Optional: build floor at current floor level
		if build_floors and turtle.getItemCount(floor_slot)>1 then
			-- lay floor across room at y=0 by placing down while traversing a simple grid
			local left_to_right = true
			for z=1, room_d do
				if left_to_right then
					for x=1, room_w do
						turtle.select(floor_slot); if turtle.getItemCount(floor_slot)>1 then turtle.placeDown() end
						if x < room_w then step_right() end
					end
				else
					for x=room_w,1,-1 do
						turtle.select(floor_slot); if turtle.getItemCount(floor_slot)>1 then turtle.placeDown() end
						if x > 1 then step_left() end
					end
				end
				left_to_right = not left_to_right
				if z < room_d then dig_forward(); safe_forward() end
			end
		end
		-- Move up for next level start
		if level < num_levels then for _=1,level_spacing do safe_up() end end
	end

	term.clear(); term.setCursorPos(1,1); print("Done. Room completed.")
end

main()


