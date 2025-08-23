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
local corner_info = {
  [1] = {name = "bottom-left (SW)", x = 0, z = 0, default_facing = 1},  -- +Z
  [2] = {name = "bottom-right (SE)", x = 1, z = 0, default_facing = 1},
  [3] = {name = "top-right (NE)", x = 1, z = 1, default_facing = -1},  -- -Z
  [4] = {name = "top-left (NW)", x = 0, z = 1, default_facing = -1}
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

-- Wizard
print("Enter total length (sizeZ, positive):")
local total_length = tonumber(read()) or error("Invalid input")
print("Enter total width (sizeX, positive):")
local total_width = tonumber(read()) or error("Invalid input")
print("Enter total depth (sizeY, positive, default 256):")
local total_depth = tonumber(read()) or 256

print("Enter number of turtles (1-4):")
local num = tonumber(read())
if num < 1 or num > 4 then error("Number must be 1-4") end

local turtles = {}
for i = 1, num do
  print("For turtle " .. i .. ", enter corner (1=bottom-left, 2=bottom-right, 3=top-right, 4=top-left):")
  local corner = tonumber(read())
  if not corner_info[corner] then error("Invalid corner") end

  print("Enter ID for " .. corner_info[corner].name .. ":")
  local id = tonumber(read())

  print("Enter facing for " .. corner_info[corner].name .. " (1=+Z, 2=-Z, default " .. corner_info[corner].default_facing .. "):")
  local facing_input = tonumber(read())
  local facing = facing_input or corner_info[corner].default_facing
  if facing ~= 1 and facing ~= -1 then
    if facing == 2 then facing = -1 else error("Invalid facing") end
  end

  turtles[i] = {corner = corner, id = id, facing = facing}
end

print("Preserve top layer (start digging below)? (1=yes, 0=no, default 0):")
local start_below = tonumber(read()) or 0

print("Debug mode? (1=yes, 0=no, default 0):")
local debug = tonumber(read()) or 0

print("Preferred split direction for 3 turtles (1=horizontal/width, 2=vertical/length, default 1):")
local pref_split = tonumber(read()) or 1
local is_horizontal_pref = (pref_split == 1)

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
  local abs_sizeZ = total_length
  local abs_sizeX = total_width
  local sizeZ = sizeZ_sign * abs_sizeZ
  local sizeX = sizeX_sign * abs_sizeX
  params_list[1] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below

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
      local sizeZ = sizeZ_sign * abs_sizeZ  -- sign per turtle
      local sizeX = sizeX_sign * abs_sizeX
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
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
      local sizeZ = sizeZ_sign * abs_sizeZ
      local sizeX = sizeX_sign * abs_sizeX
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
    end
  else
    -- Diagonal
    local h_parts_l = divide_dim(total_length, 2)
    local h_parts_w = divide_dim(total_width, 2)
    for j = 1, 2 do
      local c = turtles[j].corner
      local abs_sizeZ = (corner_info[c].z == 0) and h_parts_l[1] or h_parts_l[2]
      local abs_sizeX = (corner_info[c].x == 0) and h_parts_w[1] or h_parts_w[2]
      local sizeZ = sizeZ_sign * abs_sizeZ
      local sizeX = sizeX_sign * abs_sizeX
      params_list[j] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
    end
  end

elseif num == 3 then
  -- Balanced split
  local multiple_side, single_side, is_horizontal
  if max(count_bottom, count_top) == 2 then
    is_horizontal = true
  elseif max(count_left, count_right) == 2 then
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
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
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
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
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
      params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
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
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
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
    local sizeZ = t.facing * abs_sizeZ
    local sizeX = ( (corner_info[c].x == 0 and 1 or -1) * t.facing ) * abs_sizeX
    params_list[idx] = tostring(sizeZ) .. " " .. tostring(sizeX) .. " " .. tostring(total_depth) .. " " .. debug .. " " .. start_below
  end
end

-- Send to each
for i = 1, num do
  local id = turtles[i].id
  local param = params_list[i]
  local role = corner_info[turtles[i].corner].name .. " facing " .. (turtles[i].facing == 1 and "+Z" or "-Z")
  local payload = { command = "RUN", program = "quarry", args = param, masterId = os.getComputerID(), role = role }

  print("Sending to turtle ID " .. id .. " (" .. role .. "): quarry " .. param)
  rednet.send(id, payload, "quarry-run")
  rednet.send(id, param, "quarry-run") -- fallback
end

print("Turtles should start digging now.")

-- Note: For num=3, areas are approximately equal, but may differ slightly due to integer dimensions. Adjust total sizes for better balance if needed.
