-- quarry_multi.lua
-- Master script to launch multiple turtles with divided params for quarry

-- Auto-detect a modem and open rednet
local function findModem()
  for _, p in pairs(rs.getSides()) do
    if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then
      return p
    end
  end
  error("No modem attached to this computer.")
end

local modemSide = findModem()
rednet.open(modemSide)

local wrapped = peripheral.wrap(modemSide)
if wrapped and wrapped.isWireless and not wrapped.isWireless() then
  print("Note: Wired modem detected. Ensure turtles are cabled to the same network.")
end

-- Corner definitions (normalized x=0 left, 1 right; z=0 bottom, 1 top)
-- Turtles face EACH OTHER across the quarry for proper coordination
local corner_info = {
  [1] = {name = "bottom-left (SW)", x = 0, z = 0, default_facing = 1},   -- +Z (facing north toward turtle 4)
  [2] = {name = "bottom-right (SE)", x = 1, z = 0, default_facing = 1},  -- +Z (facing north toward turtle 3) 
  [3] = {name = "top-right (NE)", x = 1, z = 1, default_facing = -1},    -- -Z (facing south toward turtle 2)
  [4] = {name = "top-left (NW)", x = 0, z = 1, default_facing = -1}      -- -Z (facing south toward turtle 1)
}

-- Function to divide dimension into n parts
local function divide_dim(dim, n)
  local parts = {}
  local base = math.floor(dim / n)
  local rem = dim % n
  for i = 1, n do
    parts[i] = base + (i <= rem and 1 or 0)
  end
  return parts
end

-- Wizard - Get dimensions
print("=== Quarry Dimensions ===")
local total_length
while true do
  print("Enter total length (sizeZ, positive):")
  total_length = tonumber(read())
  if total_length and total_length > 0 then
    break
  else
    print("Invalid input. Please enter a positive number.")
  end
end

local total_width
while true do
  print("Enter total width (sizeX, positive):")
  total_width = tonumber(read())
  if total_width and total_width > 0 then
    break
  else
    print("Invalid input. Please enter a positive number.")
  end
end

local total_depth
while true do
  print("Enter total depth (sizeY, positive, default 256):")
  local input = read()
  if input == "" then
    total_depth = 256
    break
  else
    total_depth = tonumber(input)
    if total_depth and total_depth > 0 then
      break
    else
      print("Invalid input. Please enter a positive number or press Enter for default (256).")
    end
  end
end

-- Get number of turtles
local num
while true do
  print("Enter number of turtles (1-4):")
  num = tonumber(read())
  if num and num >= 1 and num <= 4 then
    break
  else
    print("Invalid input. Please enter a number between 1 and 4.")
  end
end

-- Setup each turtle one by one
local turtles = {}
for i = 1, num do
  print("\n=== Setting up Turtle " .. i .. " ===")
  
  -- Get corner
  local corner
  while true do
    print("Turtle placement diagram (viewed from above):")
    print("  4(NW) <-----> 3(NE)")
    print("   ^             ^")
    print("   |   QUARRY    |")
    print("   |    AREA     |")
    print("   v             v")
    print("  1(SW) <-----> 2(SE)")
    print("")
    print("Turtles face EACH OTHER across quarry:")
    print("  1 = bottom-left (SW)  - face +Z (north toward turtle 4)")
    print("  2 = bottom-right (SE) - face +Z (north toward turtle 3)")  
    print("  3 = top-right (NE)    - face -Z (south toward turtle 2)")
    print("  4 = top-left (NW)     - face -Z (south toward turtle 1)")
    print("Enter corner number for turtle " .. i .. ":")
    corner = tonumber(read())
    if corner and corner_info[corner] then
      break
    else
      print("Invalid corner. Please enter 1, 2, 3, or 4.")
    end
  end

  -- Get turtle ID
  local id
  while true do
    print("Enter turtle ID for " .. corner_info[corner].name .. ":")
    print("(Use 'id' command on the turtle to get its ID)")
    id = tonumber(read())
    if id and id > 0 then
      break
    else
      print("Invalid ID. Please enter a positive number.")
    end
  end

  -- Get facing direction
  local facing
  while true do
    print("Enter facing direction for " .. corner_info[corner].name .. ":")
    print("  1 = +Z (forward/north)")
    print("  2 = -Z (backward/south)")
    print("  (default: " .. corner_info[corner].default_facing .. ")")
    local input = read()
    if input == "" then
      facing = corner_info[corner].default_facing
      break
    else
      local facing_input = tonumber(input)
      if facing_input == 1 then
        facing = 1
        break
      elseif facing_input == 2 then
        facing = -1
        break
      else
        print("Invalid facing. Please enter 1 or 2, or press Enter for default.")
      end
    end
  end

  turtles[i] = {corner = corner, id = id, facing = facing}
  print("Turtle " .. i .. " configured: " .. corner_info[corner].name .. " (ID: " .. id .. ") facing " .. (facing == 1 and "+Z" or "-Z"))
end

-- Get options
print("\n=== Quarry Options ===")
local start_below
while true do
  print("Preserve top layer (start digging below)? (y/n, default n):")
  local input = read():lower()
  if input == "" or input == "n" or input == "no" then
    start_below = 0
    break
  elseif input == "y" or input == "yes" then
    start_below = 1
    break
  else
    print("Invalid input. Please enter 'y' for yes, 'n' for no, or press Enter for default (no).")
  end
end

local debug
while true do
  print("Debug mode? (y/n, default n):")
  local input = read():lower()
  if input == "" or input == "n" or input == "no" then
    debug = 0
    break
  elseif input == "y" or input == "yes" then
    debug = 1
    break
  else
    print("Invalid input. Please enter 'y' for yes, 'n' for no, or press Enter for default (no).")
  end
end

local auto_start
while true do
  print("Auto-start turtles (skip fuel prompt)? (y/n, default y):")
  local input = read():lower()
  if input == "" or input == "y" or input == "yes" then
    auto_start = 1
    break
  elseif input == "n" or input == "no" then
    auto_start = 0
    break
  else
    print("Invalid input. Please enter 'y' for yes, 'n' for no, or press Enter for default (yes).")
  end
end

local is_horizontal_pref = true
if num == 3 then
  while true do
    print("For 3 turtles, preferred split direction:")
    print("  1 = horizontal/width")
    print("  2 = vertical/length")
    print("  (default: horizontal)")
    local input = read()
    if input == "" or input == "1" then
      is_horizontal_pref = true
      break
    elseif input == "2" then
      is_horizontal_pref = false
      break
    else
      print("Invalid input. Please enter 1, 2, or press Enter for default (horizontal).")
    end
  end
end

-- Compute counts
local count_bottom = 0
local count_top = 0
local count_left = 0
local count_right = 0
local bottom_turtles = {}
local top_turtles = {}
local left_turtles = {}
local right_turtles = {}
for _, t in ipairs(turtles) do
  local info = corner_info[t.corner]
  if info.z == 0 then
    count_bottom = count_bottom + 1
    table.insert(bottom_turtles, t)
  else
    count_top = count_top + 1
    table.insert(top_turtles, t)
  end
  if info.x == 0 then
    count_left = count_left + 1
    table.insert(left_turtles, t)
  else
    count_right = count_right + 1
    table.insert(right_turtles, t)
  end
end

-- Function to sort turtles by position (x or z)
local function sort_by_pos(t_list, key)
  table.sort(t_list, function(a, b)
    return corner_info[a.corner][key] < corner_info[b.corner][key]
  end)
end

-- Compute parameters for each turtle
local params_list = {}
local roles = {}

for i, t in ipairs(turtles) do
  local info = corner_info[t.corner]
  local is_left = (info.x == 0)
  local desired_x_dir = is_left and 1 or -1
  local facing_sign = t.facing
  local sizeX_sign = desired_x_dir * facing_sign
  local sizeZ_sign = facing_sign

  -- Placeholder, will compute abs later
  params_list[i] = ""
  roles[i] = info.name
end

-- Now compute based on num
if num == 1 then
  local t = turtles[1]
  local info = corner_info[t.corner]
  local is_left = (info.x == 0)
  local desired_x_dir = is_left and 1 or -1
  local facing_sign = t.facing
  local sizeX_sign = desired_x_dir * facing_sign
  local sizeZ_sign = facing_sign
  
  local abs_sizeZ = total_length
  local abs_sizeX = total_width
  local sizeZ = t.facing * abs_sizeZ
  local sizeX = (corner_info[t.corner].x == 0) and abs_sizeX or (-abs_sizeX)
  params_list[1] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start

elseif num == 2 then
  -- Determine type
  local all_bottom = count_bottom == 2
  local all_top = count_top == 2
  local all_left = count_left == 2
  local all_right = count_right == 2

  if all_bottom or all_top then
    -- Horizontal aligned, split width, full length
    local group = all_bottom and bottom_turtles or top_turtles
    sort_by_pos(group, "x")
    local parts = divide_dim(total_width, 2)
    local abs_sizeZ = total_length
    for j = 1, 2 do
      local idx = 0 -- find index in turtles
      for k, tt in ipairs(turtles) do
        if tt.corner == group[j].corner then idx = k break end
      end
      local abs_sizeX = parts[j]
      local t = turtles[idx]
      local info = corner_info[t.corner]
      local is_left = (info.x == 0)
      local desired_x_dir = is_left and 1 or -1
      local facing_sign = t.facing
      local sizeX_sign = desired_x_dir * facing_sign
      local sizeZ_sign = facing_sign
      local sizeZ = t.facing * abs_sizeZ
      local sizeX = (corner_info[t.corner].x == 0) and abs_sizeX or (-abs_sizeX)
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
    end
  elseif all_left or all_right then
    -- Vertical aligned, split length, full width
    local group = all_left and left_turtles or right_turtles
    sort_by_pos(group, "z")
    local parts = divide_dim(total_length, 2)
    local abs_sizeX = total_width
    for j = 1, 2 do
      local idx = 0
      for k, tt in ipairs(turtles) do
        if tt.corner == group[j].corner then idx = k break end
      end
      local abs_sizeZ = parts[j]
      local t = turtles[idx]
      local info = corner_info[t.corner]
      local is_left = (info.x == 0)
      local desired_x_dir = is_left and 1 or -1
      local facing_sign = t.facing
      local sizeX_sign = desired_x_dir * facing_sign
      local sizeZ_sign = facing_sign
      local sizeZ = t.facing * abs_sizeZ
      local sizeX = (corner_info[t.corner].x == 0) and abs_sizeX or (-abs_sizeX)
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
    end
  else
    -- Diagonal
    local h_parts_l = divide_dim(total_length, 2)
    local h_parts_w = divide_dim(total_width, 2)
    for j = 1, 2 do
      local t = turtles[j]
      local c = t.corner
      local info = corner_info[c]
      local is_left = (info.x == 0)
      local desired_x_dir = is_left and 1 or -1
      local facing_sign = t.facing
      local sizeX_sign = desired_x_dir * facing_sign
      local sizeZ_sign = facing_sign
      local abs_sizeZ = (corner_info[c].z == 0) and h_parts_l[1] or h_parts_l[2]
      local abs_sizeX = (corner_info[c].x == 0) and h_parts_w[1] or h_parts_w[2]
      -- Use facing direction for Z, position for X
      local sizeZ = t.facing * abs_sizeZ  -- facing determines Z direction
      local sizeX = (corner_info[c].x == 0) and abs_sizeX or (-abs_sizeX)  -- position determines X direction
      params_list[j] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
    end
  end

elseif num == 3 then
  -- Balanced split
  local multiple_side, single_side, is_horizontal
  if math.max(count_bottom, count_top) == 2 then
    is_horizontal = true
  elseif math.max(count_left, count_right) == 2 then
    is_horizontal = false
  else
    is_horizontal = is_horizontal_pref
  end

  if is_horizontal then
    -- Split horizontal, balanced
    local multiple_group, single_group
    if count_bottom == 2 then
      multiple_group = bottom_turtles
      single_group = top_turtles
      multiple_is_bottom = true
    else
      multiple_group = top_turtles
      single_group = bottom_turtles
      multiple_is_bottom = false
    end
    sort_by_pos(multiple_group, "x")

    local frac = 2 / 3
    local z_multiple = math.floor(total_length * frac + 0.5)
    local z_single = total_length - z_multiple
    local w_multiple1 = math.floor(total_width / 2)
    local w_multiple2 = total_width - w_multiple1
    local w_single = total_width

    -- Multiple side
    for j = 1, 2 do
      local tt = multiple_group[j]
      local idx = 0
      for k, u in ipairs(turtles) do
        if u.corner == tt.corner then idx = k break end
      end
      local abs_sizeZ = z_multiple
      local abs_sizeX = (j == 1) and w_multiple1 or w_multiple2
      local sizeZ = turtles[idx].facing * abs_sizeZ
      local sizeX = ( (corner_info[tt.corner].x == 0 and 1 or -1) * turtles[idx].facing ) * abs_sizeX
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
    end

    -- Single side
    local tt = single_group[1]
    local idx = 0
    for k, u in ipairs(turtles) do
      if u.corner == tt.corner then idx = k break end
    end
    local abs_sizeZ = z_single
    local abs_sizeX = w_single
    local sizeZ = turtles[idx].facing * abs_sizeZ
    local sizeX = ( (corner_info[tt.corner].x == 0 and 1 or -1) * turtles[idx].facing ) * abs_sizeX
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
  else
    -- Vertical balanced
    local multiple_group, single_group
    if count_left == 2 then
      multiple_group = left_turtles
      single_group = right_turtles
      multiple_is_left = true
    else
      multiple_group = right_turtles
      single_group = left_turtles
      multiple_is_left = false
    end
    sort_by_pos(multiple_group, "z")

    local frac = 2 / 3
    local w_multiple = math.floor(total_width * frac + 0.5)
    local w_single = total_width - w_multiple
    local l_multiple1 = math.floor(total_length / 2)
    local l_multiple2 = total_length - l_multiple1

    -- Multiple side
    for j = 1, 2 do
      local tt = multiple_group[j]
      local idx = 0
      for k, u in ipairs(turtles) do
        if u.corner == tt.corner then idx = k break end
      end
      local abs_sizeX = w_multiple
      local abs_sizeZ = (j == 1) and l_multiple1 or l_multiple2
      local sizeZ = turtles[idx].facing * abs_sizeZ
      local sizeX = ( ( (multiple_is_left and 1 or -1) ) * turtles[idx].facing ) * abs_sizeX
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
    end

    -- Single side
    local tt = single_group[1]
    local idx = 0
    for k, u in ipairs(turtles) do
      if u.corner == tt.corner then idx = k break end
    end
    local abs_sizeX = w_single
    local abs_sizeZ = total_length
    local sizeZ = turtles[idx].facing * abs_sizeZ
    local sizeX = ( ( (corner_info[tt.corner].x == 0 and 1 or -1) ) * turtles[idx].facing ) * abs_sizeX
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
  end

elseif num == 4 then
  -- Split both dimensions
  local h_parts_l = divide_dim(total_length, 2)
  local h_parts_w = divide_dim(total_width, 2)

  for _, t in ipairs(turtles) do
    local c = t.corner
    local idx = 0
    for k, u in ipairs(turtles) do
      if u.corner == c then idx = k break end
    end
    local abs_sizeZ = (corner_info[c].z == 0) and h_parts_l[1] or h_parts_l[2]
    local abs_sizeX = (corner_info[c].x == 0) and h_parts_w[1] or h_parts_w[2]
    -- Calculate based on position and facing direction
    -- All turtles dig toward quarry center using their facing direction
    local sizeZ = t.facing * abs_sizeZ  -- facing determines Z direction
    local sizeX = (corner_info[c].x == 0) and abs_sizeX or (-abs_sizeX)  -- position determines X direction
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below .. " " .. auto_start
  end
end

-- Summary
print("\n=== Quarry Configuration Summary ===")
print("Dimensions: " .. total_length .. " x " .. total_width .. " x " .. total_depth)
print("Turtles: " .. num)
for i = 1, num do
  local t = turtles[i]
  print("  Turtle " .. i .. ": " .. corner_info[t.corner].name .. " (ID: " .. t.id .. ") facing " .. (t.facing == 1 and "+Z" or "-Z"))
end
print("Start below: " .. (start_below == 1 and "Yes" or "No"))
print("Debug mode: " .. (debug == 1 and "Yes" or "No"))
print("Auto-start: " .. (auto_start == 1 and "Yes" or "No"))

print("\nPress Enter to send commands to turtles, or Ctrl+T to cancel...")
read()

-- Send to each
print("\n=== Sending Commands ===")
for i = 1, num do
  local id = turtles[i].id
  local param = params_list[i]
  local role = corner_info[turtles[i].corner].name .. " facing " .. (turtles[i].facing == 1 and "+Z" or "-Z")
  local payload = { command = "RUN", program = "quarry", args = param, masterId = os.getComputerID(), role = role }

  print("Sending to turtle ID " .. id .. " (" .. role .. "): quarry " .. param)
  rednet.send(id, payload, "quarry-run")
  rednet.send(id, params_list[i], "quarry-run") -- fallback with plain string
end

print("\nCommands sent! Turtles should start digging now.")
print("Make sure each turtle is running 'quarry_listener' and has fuel in slot 1.")

-- Note: For num=3, areas are approximately equal, but may differ slightly due to integer dimensions. Adjust total sizes for better balance if needed.
