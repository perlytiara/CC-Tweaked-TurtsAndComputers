output_dir = ...
if not output_dir then
    output_dir = ''
end
path = shell.resolve(output_dir)
if not fs.isDir(path) then
    error(path .. ' is not a directory')
end

files = {
    ["LICENSE"] = [===[MIT License

Copyright (c) 2020 MerlinLikeTheWizard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]===],
    ["README.md"] = [===[# Mastermine
A fully automated strip mining network for ComputerCraft turtles!

Here's all the code for anyone who is interested! Check out the tutorial below for installation instructions.

Also, here are steps for a quick install via pastebin:

1. Place your advanced computer next to a disk drive with a blank disk in.
2. Run `pastebin get CtcSGkpc mastermine.lua`
3. Run `mastermine disk`
4. Run `disk/hub.lua`

## Play with or without PeripheralsPlusOne

I highly recommend using the PeripheralsPlusOne and its chunky turtles, but upon popular request I added the ability to disable the need for chunky turtle pairs. Just go to the config and set `use_chunky_turtles = false`

## Video description:

[![https://www.youtube.com/watch?v=2I2VXl9Pg6Q](https://img.youtube.com/vi/2I2VXl9Pg6Q/0.jpg)](https://www.youtube.com/watch?v=2I2VXl9Pg6Q)

## Video tutorial:

[![https://www.youtube.com/watch?v=2DTP1LXuiCg](https://img.youtube.com/vi/2DTP1LXuiCg/0.jpg)](https://www.youtube.com/watch?v=2DTP1LXuiCg)

## User commands:

* `on/go`
* `off/stop`
* `turtle <#> <action>`
* `update <#>`
* `reboot <#>`
* `shutdown <#>`
* `reset <#>`
* `clear <#>`
* `halt <#>`
* `return <#>`
* `hubupdate`
* `hubreboot`
* `hubshutdown`


use `*` as notation for all turtles


## Required mods:

https://www.curseforge.com/minecraft/mc-mods/cc-tweaked

https://github.com/rolandoislas/PeripheralsPlusOne

Required by PeripheralsPlusOne: https://www.curseforge.com/minecraft/mc-mods/the-framework]===],
    ["hub.lua"] = [===[if fs.exists('/disk/hub_files/session_id') then
    fs.delete('/disk/hub_files/session_id')
end
if fs.exists('/session_id') then
    fs.copy('/session_id', '/disk/hub_files/session_id')
end
if fs.exists('/disk/hub_files/mine') then
    fs.delete('/disk/hub_files/mine')
end
if fs.exists('/mine') then
    fs.copy('/mine', '/disk/hub_files/mine')
end

for _, filename in pairs(fs.list('/')) do
    if filename ~= 'rom' and filename ~= 'disk' and filename ~= 'openp' and filename ~= 'ppp' and filename ~= 'persistent' then
        fs.delete(filename)
    end
end
for _, filename in pairs(fs.list('/disk/hub_files')) do
    fs.copy('/disk/hub_files/' .. filename, '/' .. filename)
end
os.reboot()]===],
    ["pocket.lua"] = [===[local src, dest = ...

fs.copy(fs.combine(src, 'pocket_files/update'), fs.combine(dest, 'update'))
file = fs.open(fs.combine(dest, 'hub_id'), 'w')
file.write(os.getComputerID())
file.close()]===],
    ["turtle.lua"] = [===[for _, filename in pairs(fs.list('/')) do
    if filename ~= 'rom' and filename ~= 'disk' and filename ~= 'openp' and filename ~= 'ppp' and filename ~= 'persistent' then
        fs.delete(filename)
    end
end

for _, filename in pairs(fs.list('/disk/turtle_files')) do
    fs.copy('/disk/turtle_files/' .. filename, '/' .. filename)
end

print("Enter ID of Hub computer to link to: ")
hub_id = tonumber(read())
if hub_id == nil then
    error("Invalid ID")
end

file = fs.open('/hub_id', 'w')
file.write(hub_id)
file.close()

print("Linked")

sleep(1)
os.reboot()]===],
    ["turtle_files/actions.lua"] = [===[inf = basics.inf
str_xyz = basics.str_xyz

--lua_print = print
--log_file = fs.open('log.txt', 'w')
--function print(thing)
--    lua_print(thing)
--    log_file.writeLine(thing)
--end
    

bumps = {
    north = { 0,  0, -1},
    south = { 0,  0,  1},
    east  = { 1,  0,  0},
    west  = {-1,  0,  0},
}


left_shift = {
    north = 'west',
    south = 'east',
    east  = 'north',
    west  = 'south',
}


right_shift = {
    north = 'east',
    south = 'west',
    east  = 'south',
    west  = 'north',
}


reverse_shift = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}


move = {
    forward = turtle.forward,
    up      = turtle.up,
    down    = turtle.down,
    back    = turtle.back,
    left    = turtle.turnLeft,
    right   = turtle.turnRight
}


detect = {
    forward = turtle.detect,
    up      = turtle.detectUp,
    down    = turtle.detectDown
}


inspect = {
    forward = turtle.inspect,
    up      = turtle.inspectUp,
    down    = turtle.inspectDown
}


dig = {
    forward = turtle.dig,
    up      = turtle.digUp,
    down    = turtle.digDown
}

attack = {
    forward = turtle.attack,
    up      = turtle.attackUp,
    down    = turtle.attackDown
}


getblock = {
    
    up = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        return {x = pos.x, y = pos.y + 1, z = pos.z}
    end,

    down = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        return {x = pos.x, y = pos.y - 1, z = pos.z}
    end,

    forward = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        local bump = bumps[fac]
        return {x = pos.x + bump[1], y = pos.y + bump[2], z = pos.z + bump[3]}
    end,
    
    back = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        local bump = bumps[fac]
        return {x = pos.x - bump[1], y = pos.y - bump[2], z = pos.z - bump[3]}
    end,
    
    left = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        local bump = bumps[left_shift[fac]]
        return {x = pos.x + bump[1], y = pos.y + bump[2], z = pos.z + bump[3]}
    end,
    
    right = function(pos, fac)
        if not pos then pos = state.location end
        if not fac then fac = state.orientation end
        local bump = bumps[right_shift[fac]]
        return {x = pos.x + bump[1], y = pos.y + bump[2], z = pos.z + bump[3]}
    end,
}


function digblock(direction)
    dig[direction]()
    return true
end


function delay(duration)
    sleep(duration)
    return true
end


function up()
    return go('up')
end


function forward()
    return go('forward')
end


function down()
    return go('down')
end


function back()
    return go('back')
end


function left()
    return go('left')
end


function right()
    return go('right')
end


function follow_route(route)
    for step in route:gmatch'.' do
        if step == 'u' then
            if not go('up')      then return false end
        elseif step == 'f' then
            if not go('forward') then return false end
        elseif step == 'd' then
            if not go('down')    then return false end
        elseif step == 'b' then
            if not go('back')    then return false end
        elseif step == 'l' then
            if not go('left')    then return false end
        elseif step == 'r' then
            if not go('right')   then return false end
        end
    end
    return true
end
                    
                    
function face(orientation)
    if state.orientation == orientation then
        return true
    elseif right_shift[state.orientation] == orientation then
        if not go('right') then return false end
    elseif left_shift[state.orientation] == orientation then
        if not go('left') then return false end
    elseif right_shift[right_shift[state.orientation]] == orientation then
        if not go('right') then return false end
        if not go('right') then return false end
    else
        return false
    end
    return true
end


function log_movement(direction)
    if direction == 'up' then
        state.location.y = state.location.y +1
    elseif direction == 'down' then
        state.location.y = state.location.y -1
    elseif direction == 'forward' then
        bump = bumps[state.orientation]
        state.location = {x = state.location.x + bump[1], y = state.location.y + bump[2], z = state.location.z + bump[3]}
    elseif direction == 'back' then
        bump = bumps[state.orientation]
        state.location = {x = state.location.x - bump[1], y = state.location.y - bump[2], z = state.location.z - bump[3]}
    elseif direction == 'left' then
        state.orientation = left_shift[state.orientation]
    elseif direction == 'right' then
        state.orientation = right_shift[state.orientation]
    end
    return true
end


function go(direction, nodig)
    if not nodig then
        if detect[direction] then
            if detect[direction]() then
                safedig(direction)
            end
        end
    end
    if not move[direction] then
        return false
    end
    if not move[direction]() then
        if attack[direction] then
            attack[direction]()
        end
        return false
    end
    log_movement(direction)
    return true
end


function go_to_axis(axis, coordinate, nodig)
    local delta = coordinate - state.location[axis]
    if delta == 0 then
        return true
    end
    
    if axis == 'x' then
        if delta > 0 then
            if not face('east') then return false end
        else
            if not face('west') then return false end
        end
    elseif axis == 'z' then
        if delta > 0 then
            if not face('south') then return false end
        else
            if not face('north') then return false end
        end
    end
    
    for i = 1, math.abs(delta) do
        if axis == 'y' then
            if delta > 0 then
                if not go('up', nodig) then return false end
            else
                if not go('down', nodig) then return false end
            end
        else
            if not go('forward', nodig) then return false end
        end
    end
    return true
end


function go_to(end_location, end_orientation, path, nodig)
    if path then
        for axis in path:gmatch'.' do
            if not go_to_axis(axis, end_location[axis], nodig) then return false end
        end
    elseif end_location.path then
        for axis in end_location.path:gmatch'.' do
            if not go_to_axis(axis, end_location[axis], nodig) then return false end
        end
    else
        return false
    end
    if end_orientation then
        if not face(end_orientation) then return false end
    elseif end_location.orientation then
        if not face(end_location.orientation) then return false end
    end
    return true
end


function go_route(route, xyzo)
    local xyz_string
    if xyzo then
        xyz_string = str_xyz(xyzo)
    end
    local location_str = basics.str_xyz(state.location)
    while route[location_str] and location_str ~= xyz_string do
        if not go_to(route[location_str], nil, 'xyz') then return false end
        location_str = basics.str_xyz(state.location)
    end
    if xyzo then
        if location_str ~= xyz_string then
            return false
        end
        if xyzo.orientation then
            if not face(xyzo.orientation) then return false end
        end
    end
    return true
end


function go_to_home()
    state.updated_not_home = nil
    if basics.in_area(state.location, config.locations.home_area) then
        return true
    elseif basics.in_area(state.location, config.locations.greater_home_area) then
        if not go_to_home_exit() then return false end
    elseif basics.in_area(state.location, config.locations.waiting_room_area) then
        if not go_to(config.locations.mine_exit, nil, config.paths.waiting_room_to_mine_exit, true) then return false end
    elseif state.location.y < config.locations.mine_enter.y then
        return false
    end
    if config.locations.main_loop_route[basics.str_xyz(state.location)] then
        if not go_route(config.locations.main_loop_route, config.locations.home_enter) then return false end
    elseif basics.in_area(state.location, config.locations.control_room_area) then
        if not go_to(config.locations.home_enter, nil, config.paths.control_room_to_home_enter, true) then return false end
    else
        return false
    end
    if not forward() then return false end
    while detect.down() do
        if not forward() then return false end
    end
    if not down() then return false end
    if not right() then return false end
    if not right() then return false end
    return true
end


function go_to_home_exit()
    if basics.in_area(state.location, config.locations.greater_home_area) then
        if not go_to(config.locations.home_exit, nil, config.paths.home_to_home_exit) then return false end
    elseif config.locations.main_loop_route[basics.str_xyz(state.location)] then
        if not go_route(config.locations.main_loop_route, config.locations.home_exit) then return false end
    else
        return false
    end
    return true
end


function go_to_item_drop()
    if not config.locations.main_loop_route[basics.str_xyz(state.location)] then
        if not go_to_home() then return false end
        if not go_to_home_exit() then return false end
    end
    if not go_route(config.locations.main_loop_route, config.locations.item_drop) then return false end
    return true
end


function go_to_refuel()
    if not config.locations.main_loop_route[basics.str_xyz(state.location)] then
        if not go_to_home() then return false end
        if not go_to_home_exit() then return false end
    end
    if not go_route(config.locations.main_loop_route, config.locations.refuel) then return false end
    return true
end


function go_to_waiting_room()
    if not basics.in_area(state.location, config.locations.waiting_room_line_area) then
        if not go_to_home() then return false end
    end
    if not go_to(config.locations.waiting_room, nil, config.paths.home_to_waiting_room) then return false end
    return true
end


function go_to_mine_enter()
    if not go_route(config.locations.waiting_room_to_mine_enter_route) then return false end
    return true
end


function go_to_strip(strip)
    if state.location.y < config.locations.mine_enter.y or basics.in_location(state.location, config.locations.mine_enter) then
        if state.type == 'mining' then
            local bump = bumps[strip.orientation]
            strip = {
                x = strip.x + bump[1],
                y = strip.y + bump[2],
                z = strip.z + bump[3],
                orientation = strip.orientation
            }
        end
        if not go_to(strip, nil, config.paths.mine_enter_to_strip) then return false end
        return true
    end
end


function go_to_mine_exit(strip)
    if state.location.y < config.locations.mine_enter.y or (state.location.x == config.locations.mine_exit.x and state.location.z == config.locations.mine_exit.z) then
        if state.location.x == config.locations.mine_enter.x and state.location.z == config.locations.mine_enter.z then
            -- If directly under mine_enter, shift over to exit
            if not go_to_axis('z', config.locations.mine_exit.z) then return false end
        elseif state.location.x ~= config.locations.mine_exit.x or state.location.z ~= config.locations.mine_exit.z then
            -- If NOT directly under mine_exit go to proper y
            if not go_to_axis('y', strip.y + 1) then return false end
            if state.location.z ~= config.locations.mine_enter.z and strip.z ~= config.locations.mine_enter.z then
                -- If not in main_shaft, find your strip
                if not go_to_axis('x', strip.x) then return false end
            end
            if state.location.x ~= config.locations.mine_exit.x then
                -- If not in strip x = origin, go to main_shaft
                if not go_to_axis('z', config.locations.mine_enter.z) then return false end
            end
        end
        if not go_to(config.locations.mine_exit, nil, 'xzy') then return false end
        return true
    end
end


function safedig(direction)
    -- DIG IF BLOCK NOT ON BLACKLIST
    if not direction then
        direction = 'forward'
    end
    
    local block_name = ({inspect[direction]()})[2].name
    if block_name then
        for _, word in pairs(config.dig_disallow) do
            if string.find(string.lower(block_name), word) then
                return false
            end
        end

        return dig[direction]()
    end
    return true
end


function dump_items(omit)
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 and ((not omit) or (not omit[turtle.getItemDetail(slot).name])) then
            turtle.select(slot)
            if not turtle.drop() then return false end
        end
    end
    return true
end
    


function prepare(min_fuel_amount)
    if state.item_count > 0 then
        if not go_to_item_drop() then return false end
        if not dump_items(config.fuelnames) then return false end
    end
    local min_fuel_amount = min_fuel_amount + config.fuel_padding
    if not go_to_refuel() then return false end
    if not dump_items() then return false end
    turtle.select(1)
    if turtle.getFuelLevel() ~= 'unlimited' then
        while turtle.getFuelLevel() < min_fuel_amount do
            if not turtle.suck(math.min(64, math.ceil(min_fuel_amount / config.fuel_per_unit))) then return false end
            turtle.refuel()
        end
    end
    return true
end


function calibrate()
    -- GEOPOSITION BY MOVING TO ADJACENT BLOCK AND BACK
    local sx, sy, sz = gps.locate()
--    if sx == config.interface.x and sy == config.interface.y and sz == config.interface.z then
--        refuel()
--    end
    if not sx or not sy or not sz then
        return false
    end
    for i = 1, 4 do
        -- TRY TO FIND EMPTY ADJACENT BLOCK
        if not turtle.detect() then
            break
        end
        if not turtle.turnRight() then return false end
    end
    if turtle.detect() then
        -- TRY TO DIG ADJACENT BLOCK
        for i = 1, 4 do
            safedig('forward')
            if not turtle.detect() then
                break
            end
            if not turtle.turnRight() then return false end
        end
        if turtle.detect() then
            return false
        end
    end
    if not turtle.forward() then return false end
    local nx, ny, nz = gps.locate()
    if nx == sx + 1 then
        state.orientation = 'east'
    elseif nx == sx - 1 then
        state.orientation = 'west'
    elseif nz == sz + 1 then
        state.orientation = 'south'
    elseif nz == sz - 1 then
        state.orientation = 'north'
    else
        return false
    end
    state.location = {x = nx, y = ny, z = nz}
    print('Calibrated to ' .. str_xyz(state.location, state.orientation))
    
    back()
    
    if basics.in_area(state.location, config.locations.home_area) then
        face(left_shift[left_shift[config.locations.homes.increment]])
    end
    
    return true
end


function initialize(session_id, config_values)
    -- INITIALIZE TURTLE
    
    state.session_id = session_id
    
    -- COPY CONFIG DATA INTO MEMORY
    for k, v in pairs(config_values) do
        config[k] = v
    end
    
    -- DETERMINE TURTLE TYPE
    state.peripheral_left = peripheral.getType('left')
    state.peripheral_right = peripheral.getType('right')
    if state.peripheral_left == 'chunkLoader' or state.peripheral_right == 'chunkLoader' or state.peripheral_left == 'chunky' or state.peripheral_right == 'chunky' then
        state.type = 'chunky'
        for k, v in pairs(config.chunky_turtle_locations) do
            config.locations[k] = v
        end
    else
        state.type = 'mining'
        for k, v in pairs(config.mining_turtle_locations) do
            config.locations[k] = v
        end
        if state.peripheral_left == 'modem' then
            state.peripheral_right = 'pick'
        else
            state.peripheral_left = 'pick'
        end
    end
    
    state.request_id = 1
    state.initialized = true
    return true
end


function getcwd()
    local running_program = shell.getRunningProgram()
    local program_name = fs.getName(running_program)
    return "/" .. running_program:sub(1, #running_program - #program_name)
end


function pass()
    return true
end


function dump(direction)
    if not face(direction) then return false end
    if ({inspect.forward()})[2].name ~= 'computercraft:turtle_advanced' then
        return false
    end
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.drop()
        end
    end
    return true
end


function checkTags(data)
    if type(data.tags) ~= 'table' then
        return false
    end
    if not config.blocktags then
        return false
    end
    for k,v in pairs(data.tags) do
        if config.blocktags[k] then
            return true
        end
    end
    return false
end


function detect_ore(direction)
    local block = ({inspect[direction]()})[2]
    if config.orenames[block.name] then
        return true
    elseif checkTags(block) then
        return true
    end
    return false
end


function scan(valid, ores)
    local checked_left  = false
    local checked_right = false
    
    local f = str_xyz(getblock.forward())
    local u = str_xyz(getblock.up())
    local d = str_xyz(getblock.down())
    local l = str_xyz(getblock.left())
    local r = str_xyz(getblock.right())
    local b = str_xyz(getblock.back())
    
    if not valid[f] and valid[f] ~= false then
        valid[f] = detect_ore('forward')
        ores[f] = valid[f]
    end
    if not valid[u] and valid[u] ~= false then
        valid[u] = detect_ore('up')
        ores[u] = valid[u]
    end
    if not valid[d] and valid[d] ~= false then
        valid[d] = detect_ore('down')
        ores[d] = valid[d]
    end
    if not valid[l] and valid[l] ~= false then
        left()
        checked_left = true
        valid[l] = detect_ore('forward')
        ores[l] = valid[l]
    end
    if not valid[r] and valid[r] ~= false then
        right()
        if checked_left then
            right()
        end
        checked_right = true
        valid[r] = detect_ore('forward')
        ores[r] = valid[r]
    end
    if not valid[b] and valid[b] ~= false then
        if checked_right then
            right()
        elseif checked_left then
            left()
        else
            right(2)
        end
        valid[b] = detect_ore('forward')
        ores[b] = valid[b]
    end
end


function fastest_route(area, pos, fac, end_locations)
    local queue = {}
    local explored = {}
    table.insert(queue,
        {
            coords = {x = pos.x, y = pos.y, z = pos.z},
            facing = fac,
            path = '',
        }
    )
    explored[str_xyz(pos, fac)] = true

    while #queue > 0 do
        local node = table.remove(queue, 1)
        if end_locations[str_xyz(node.coords)] or end_locations[str_xyz(node.coords, node.facing)] then
            return node.path
        end
        for _, step in pairs({
                {coords = node.coords,                                facing = left_shift[node.facing],  path = node.path .. 'l'},
                {coords = node.coords,                                facing = right_shift[node.facing], path = node.path .. 'r'},
                {coords = getblock.forward(node.coords, node.facing), facing = node.facing,              path = node.path .. 'f'},
                {coords = getblock.up(node.coords, node.facing),      facing = node.facing,              path = node.path .. 'u'},
                {coords = getblock.down(node.coords, node.facing),    facing = node.facing,              path = node.path .. 'd'},
                }) do
            explore_string = str_xyz(step.coords, step.facing)
            if not explored[explore_string] and (not area or area[str_xyz(step.coords)]) then
                explored[explore_string] = true
                table.insert(queue, step)
            end
        end
    end
end


function mine_vein(direction)
    if not face(direction) then return false end
    
    -- Log starting location
    local start = str_xyz({x = state.location.x, y = state.location.y, z = state.location.z}, state.orientation)

    -- Begin block map
    local valid = {}
    local ores = {}
    valid[str_xyz(state.location)] = true
    valid[str_xyz(getblock.back(state.location, state.orientation))] = false
    for i = 1, config.vein_max do

        -- Scan adjacent
        scan(valid, ores)

        -- Search for nearest ore
        local route = fastest_route(valid, state.location, state.orientation, ores)

        -- Check if there is one
        if not route then
            break
        end

        -- Retrieve ore
        turtle.select(1)
        if not follow_route(route) then return false end
        ores[str_xyz(state.location)] = nil

    end

    if not follow_route(fastest_route(valid, state.location, state.orientation, {[start] = true})) then return false end

    if detect.up() then
        safedig('up')
    end
    
    return true
end


function clear_gravity_blocks()
    for _, direction in pairs({'forward', 'up'}) do
        while config.gravitynames[ ({inspect[direction]()})[2].name ] do
            safedig(direction)
            sleep(1)
        end
    end
    return true
end]===],
    ["turtle_files/basics.lua"] = [===[inf = 1e309

bumps = {
    north = { 0,  0, -1},
    south = { 0,  0,  1},
    east  = { 1,  0,  0},
    west  = {-1,  0,  0},
}

left_shift = {
    north = 'west',
    south = 'east',
    east  = 'north',
    west  = 'south',
}

right_shift = {
    north = 'east',
    south = 'west',
    east  = 'south',
    west  = 'north',
}

reverse_shift = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}

function dprint(thing)
    -- PRINT; IF TABLE PRINT EACH ITEM
    if type(thing) == 'table' then
        for k, v in pairs(thing) do
            print(tostring(k) .. ': ' .. tostring(v))
        end
    else
        print(thing)
    end
    return true
end


function str_xyz(coords, facing)
    if facing then
        return coords.x .. ',' .. coords.y .. ',' .. coords.z .. ':' .. facing
    else
        return coords.x .. ',' .. coords.y .. ',' .. coords.z
    end
end


function distance(point_1, point_2)
    return math.abs(point_1.x - point_2.x)
         + math.abs(point_1.y - point_2.y)
         + math.abs(point_1.z - point_2.z)
end


function in_area(xyz, area)
    return xyz.x <= area.max_x and xyz.x >= area.min_x and xyz.y <= area.max_y and xyz.y >= area.min_y and xyz.z <= area.max_z and xyz.z >= area.min_z
end


function in_location(xyzo, location)
    for _, axis in pairs({'x', 'y', 'z'}) do
        if location[axis] then
            if location[axis] ~= xyzo[axis] then
                return false
            end
        end
    end
    return true
end]===],
    ["turtle_files/config.lua"] = [===[]===],
    ["turtle_files/mastermine.lua"] = [===[function parse_requests()
    -- PROCESS ALL REDNET REQUESTS
    while #state.requests > 0 do
        local request = table.remove(state.requests, 1)
        sender, message, protocol = request[1], request[2], request[3]
        if message.action == 'shutdown' then
            os.shutdown()
        elseif message.action == 'reboot' then
            os.reboot()
        elseif message.action == 'update' then
            os.run({}, '/update')
        elseif message.request_id == -1 or message.request_id == state.request_id then -- MAKE SURE REQUEST IS CURRENT
            if state.initialized or message.action == 'initialize' then
                print('Directive: ' .. message.action)
                state.busy = true
                state.success = actions[message.action](unpack(message.data)) -- EXECUTE DESIRED FUNCTION WITH DESIRED ARGUMENTS
                state.busy = false
                if not state.success then
                    sleep(1)
                end
                state.request_id = state.request_id + 1
            end
        end
    end
end


function main()
    state.last_ping = os.clock()
    while true do
        parse_requests()
        sleep(0.3)
    end
end


main()]===],
    ["turtle_files/receive.lua"] = [===[-- CONTINUOUSLY RECIEVE REDNET MESSAGES
while true do
    signal = {rednet.receive('mastermine')}
    if signal[2].action == 'shutdown' then
        os.shutdown()
    elseif signal[2].action == 'reboot' then
        os.reboot()
    elseif signal[2].action == 'update' then
        os.run({}, '/update')
    else
        table.insert(state.requests, signal)
    end
end]===],
    ["turtle_files/report.lua"] = [===[-- CONTINUOUSLY BROADCAST STATUS REPORTS
hub_id = tonumber(fs.open('/hub_id', 'r').readAll())

while true do

    state.item_count = 0
    state.empty_slot_count = 16
    for slot = 1, 16 do
        slot_item_count = turtle.getItemCount(slot)
        if slot_item_count > 0 then
            state.empty_slot_count = state.empty_slot_count - 1
            state.item_count = state.item_count + slot_item_count
        end
    end
    
    rednet.send(hub_id, {
            session_id       = state.session_id,
            request_id       = state.request_id,
            turtle_type      = state.type,
            peripheral_left  = state.peripheral_left,
            peripheral_right = state.peripheral_right,
            updated_not_home = state.updated_not_home,
            location         = state.location,
            orientation      = state.orientation,
            fuel_level       = turtle.getFuelLevel(),
            item_count       = state.item_count,
            empty_slot_count = state.empty_slot_count,
            distance         = state.distance,
            strip            = state.strip,
            success          = state.success,
            busy             = state.busy,
        }, 'turtle_report')
    
    sleep(0.5)
    
end]===],
    ["turtle_files/startup.lua"] = [===[-- SET LABEL
os.setComputerLabel('Turtle ' .. os.getComputerID())

-- INITIALIZE APIS
if fs.exists('/apis') then
    fs.delete('/apis')
end
fs.makeDir('/apis')
fs.copy('/config.lua', '/apis/config')
fs.copy('/state.lua', '/apis/state')
fs.copy('/basics.lua', '/apis/basics')
fs.copy('/actions.lua', '/apis/actions')
os.loadAPI('/apis/config')
os.loadAPI('/apis/state')
os.loadAPI('/apis/basics')
os.loadAPI('/apis/actions')


-- OPEN REDNET
for _, side in pairs({'back', 'top', 'left', 'right'}) do
    if peripheral.getType(side) == 'modem' then
        rednet.open(side)
        break
    end
end


-- IF UPDATED PRINT "UPDATED"
if fs.exists('/updated') then
    fs.delete('/updated')
    print('UPDATED')
    state.updated_not_home = true
end


-- LAUNCH PROGRAMS AS SEPARATE THREADS
multishell.launch({}, '/report.lua')
multishell.launch({}, '/receive.lua')
multishell.launch({}, '/mastermine.lua')
multishell.setTitle(2, 'report')
multishell.setTitle(3, 'receive')
multishell.setTitle(4, 'mastermine')]===],
    ["turtle_files/state.lua"] = [===[request_id = 1
requests = {}
busy = false]===],
    ["turtle_files/update"] = [===[hub_id = tonumber(fs.open('/hub_id', 'r').readAll())

print('Sending update request...')
rednet.send(hub_id, '/disk/turtle_files/', 'update_request')
local sender, message, protocal = rednet.receive('update_package')

for _, file_name in pairs(fs.list('/')) do
    if file_name ~= 'rom' and file_name ~= 'persistent' then
        fs.delete(file_name)
    end
end

for file_name, file_contents in pairs(message) do
    file = fs.open(file_name, 'w')
    file.write(file_contents)
    file.close()
end

os.reboot()]===],
    ["turtle_files/updated"] = [===[]===],
    ["pocket_files/info.lua"] = [===[hub_id = tonumber(fs.open('/hub_id', 'r').readAll())

while true do
    sender, hub_state, _ = rednet.receive('hub_report')
    if sender == hub_id then
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
        term.write('POWER: ')
        if hub_state.on then
            term.setTextColor(colors.green)
            print('ON')
        else
            term.setTextColor(colors.red)
            print('OFF')
        end
        term.setTextColor(colors.white)
        term.write('TURTLES PARKED: ')
        if hub_state.turtles_parked >= hub_state.turtle_count then
            term.setTextColor(colors.green)
        else
            term.setTextColor(colors.red)
        end
        term.write(hub_state.turtles_parked)
    end
end]===],
    ["pocket_files/report.lua"] = [===[-- CONTINUOUSLY BROADCAST STATUS REPORTS
hub_id = tonumber(fs.open('/hub_id', 'r').readAll())

while true do
    
    local x, y, z = gps.locate()
    
    rednet.send(hub_id, {
            location = {x = x, y = y, z = z},
        }, 'pocket_report')
    
    sleep(0.5)
    
end]===],
    ["pocket_files/startup.lua"] = [===[-- SET LABEL
os.setComputerLabel('pocket ' .. os.getComputerID())


-- OPEN REDNET
rednet.open('back')


-- IF UPDATED PRINT "UPDATED"
if fs.exists('/updated') then
    fs.delete('/updated')
    print('UPDATED')
end


-- LAUNCH PROGRAMS AS SEPARATE THREADS
multishell.launch({}, '/user.lua')
multishell.launch({}, '/info.lua')
multishell.launch({}, '/report.lua')
multishell.setTitle(2, 'usr')
multishell.setTitle(3, 'info')
multishell.setTitle(4, 'rep')]===],
    ["pocket_files/update"] = [===[hub_id = tonumber(fs.open('/hub_id', 'r').readAll())
rednet.open('back')

print('Sending update request...')
rednet.broadcast('/disk/pocket_files/', 'update_request')
local sender, message, protocal = rednet.receive('update_package')

for _, file_name in pairs(fs.list('/')) do
    if file_name ~= 'rom' and file_name ~= 'disk' and file_name ~= 'persistent' then
        fs.delete(file_name)
    end
end

for file_name, file_contents in pairs(message) do
    file = fs.open(file_name, 'w')
    file.write(file_contents)
    file.close()
end

os.reboot()]===],
    ["pocket_files/updated"] = [===[]===],
    ["pocket_files/user.lua"] = [===[-- CONTINUOUSLY AWAIT USER INPUT AND PLACE IN TABLE
while true do
    rednet.broadcast(read(), 'user_input')
end]===],
    ["hub_files/basics.lua"] = [===[inf = 1e309

bumps = {
    north = { 0,  0, -1},
    south = { 0,  0,  1},
    east  = { 1,  0,  0},
    west  = {-1,  0,  0},
}

left_shift = {
    north = 'west',
    south = 'east',
    east  = 'north',
    west  = 'south',
}

right_shift = {
    north = 'east',
    south = 'west',
    east  = 'south',
    west  = 'north',
}

reverse_shift = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}

function dprint(thing)
    -- PRINT; IF TABLE PRINT EACH ITEM
    if type(thing) == 'table' then
        for k, v in pairs(thing) do
            print(tostring(k) .. ': ' .. tostring(v))
        end
    else
        print(thing)
    end
    return true
end


function str_xyz(coords, facing)
    if facing then
        return coords.x .. ',' .. coords.y .. ',' .. coords.z .. ':' .. facing
    else
        return coords.x .. ',' .. coords.y .. ',' .. coords.z
    end
end


function distance(point_1, point_2)
    return math.abs(point_1.x - point_2.x)
         + math.abs(point_1.y - point_2.y)
         + math.abs(point_1.z - point_2.z)
end


function in_area(xyz, area)
    return xyz.x <= area.max_x and xyz.x >= area.min_x and xyz.y <= area.max_y and xyz.y >= area.min_y and xyz.z <= area.max_z and xyz.z >= area.min_z
end


function in_location(xyzo, location)
    for _, axis in pairs({'x', 'y', 'z'}) do
        if location[axis] then
            if location[axis] ~= xyzo[axis] then
                return false
            end
        end
    end
    return true
end]===],
    ["hub_files/config.lua"] = [===[inf = 1e309

---==[ MINE ]==---


-- LOCATION OF THE CENTER OF THE MINE
--     the y value should be set to the height
--     1 above the surface:
--
--            Y
--     ####### #######
--     ####### #######
mine_entrance = {x = 104, y = 76, z = 215}
c = mine_entrance


-- WHETHER OR NOT TURTLES NEED PAIRS
--     added this because a good number of
--     people were asking for the ability to
--     disale chunky turtles in case they
--     couldn't access the peripherals mod.
--     WARNING: not using chunky turtles will
--     result in narcoleptic turtles!
use_chunky_turtles = true


-- SPACE IN BLOCKS BETWEEN MINESHAFTS
--     too close means less chance of finding
--     ore veins, too far means longer commute
--     times for turtles.
grid_width = 8


-- MAXIMUM MINING AMOUNT PER TRIP
-- PER TURTLE
--     most efficient would be to make this
--     number huge, but turtles may be gone a
--     while (plus harder to recall).
mission_length = 150


-- MAXIMUM BLOCKS A TURTLE MINES IN A
-- SINGLE ORE VEIN
--     veins can contain multiple types of ore
--     and still count as one. also turtles will
--     continue on a vein even when their
--     inventory fills up, so this prevents them
--     losing too many rousources.
vein_max = 64


-- EXTRA FUEL FOR TURTLES TO BRING ALONG,
-- JUST IN CASE
fuel_padding = 30


-- FUEL PER ITEM 
--     for coal default is 80. Other fuel sources
--     can be used without changing this number,
--     should be fine.
fuel_per_unit = 80


-- TIME AFTER LAST PING TO DECLARE TURTLE
-- DISCONNECTED
turtle_timeout = 5


-- TIME AFTER LAST PING TO DECLARE POCKET
-- COMPUTER DISCONNECTED
pocket_timeout = 5


-- TIME TO WAIT AFTER SENDING TASK WITH NO
-- RESPONSE TO RESEND
task_timeout = 0.5


-- EVERY BLOCK NAME CONTAINING ANY OF THESE
-- STRINGS WILL NOT BE MINED
--     e.g. "chest" will prevent "minecraft:trapped_chest".
--     ore types should not be put on this list,
--     but if not desired should be removed from
--     <orenames> below.
dig_disallow = {
    'computer',
    'chest',
    'chair',
}


mine_levels = {
    -- LEVELS INCLUDED IN THE MINE
    --     turtles will pick randomly with weight
    --     between each listed level.
    --
    -- Level chances should sum to 1.0
    -- e.g.
    -- 
    -- {level = 50, chance = 0.3},
    -- {level = 40, chance = 0.2},
    -- {level = 12, chance = 0.5},

    {level = 63, chance = 1.0},
}


paths = {
    -- THE ORDER IN WHICH TURTLES WILL
    -- TRAVERSE AXES BETWEEN AREAS
    --     recommended not to change this one.
    home_to_home_exit          = 'zyx',
    control_room_to_home_enter = 'yzx',
    home_to_waiting_room       = 'zyx',
    waiting_room_to_mine_exit  = 'yzx',
    mine_enter_to_strip        = 'yxz',
}


locations = {
    -- THE VARIUS PLACES THE TURTLES MOVE
    -- BETWEEN
    --     coordinates are relative to the
    --     <mine_center> variable. areas are for
    --     altering turtle behavior to prevent
    --     collisions and stuff.

     -- THE BLOCK TURTLES WILL GO TO BEFORE
     -- DECENDING
    mine_enter = {x = c.x+0, y = c.y+0, z = c.z+0},

     -- THE BLOCK TURTLES WILL COME UP TO
     -- FROM THE MINE
     --     one block higher by default.
    mine_exit = {x = c.x+0, y = c.y+1, z = c.z+1},

     -- THE BLOCK TURTLES GO TO IN ORDER
     -- TO ACCESS THE CHEST FOR ITEMS
    item_drop = {x = c.x+2, y = c.y+1, z = c.z+1, orientation = 'east'},

     -- THE BLOCK TURTLES GO TO IN ORDER
     -- TO ACCESS THE CHEST FOR FUEL
    refuel = {x = c.x+2, y = c.y+1, z = c.z+0, orientation = 'east'},

     -- THE AREA ENCOMPASSING TURTLE HOMES
     --     where they sleep.
    greater_home_area = {
        min_x =  -inf,
        max_x = c.x-3,
        min_y = c.y+0,
        max_y = c.y+1,
        min_z = c.z-1,
        max_z = c.z+2
    },

     -- THE ROOM WHERE THE MAGIC HAPPENS
     --     turtles can find there way home from
     --     here.
    control_room_area = {
        min_x = c.x-16,
        max_x = c.x+8,
        min_y = c.y+0,
        max_y = c.y+8,
        min_z = c.z-8,
        max_z = c.z+8
    },

     -- WHERE TURTLES QUEUE TO BE PAIRED UP
    waiting_room_line_area = {
        min_x =  -inf,
        max_x = c.x-2,
        min_y = c.y+0,
        max_y = c.y+0,
        min_z =  c.z+0,
        max_z = c.z+1
    },

     -- THE AREA ENCOMPASSING BOTH WHERE
     -- TURTLES PAIR UP, AND THE PATH THEY
     -- TAKE TO THE MINE ENTRANCE
    waiting_room_area = {
        min_x = c.x-2,
        max_x = c.x+0,
        min_y = c.y+0,
        max_y = c.y+0,
        min_z =  c.z+0,
        max_z = c.z+1
    },

     -- THE LOOP TURTLES GO IN BETWEEN THEIR
     -- HOMES, THE ITEM DROP STATION, AND THE
     -- REFUELING STATION
     --     routes work like linked lists.
     --     keys are current positions, and
     --     values are the associated ajecent
     --     blocks to move to. this loop should
     --     be closed, and it should not be
     --     possible for a collision to occur
     --     between a turtle following the loop,
     --     and a turtle pairing, traveling to
     --     the mine entrance, or any other
     --     movement.
    main_loop_route = {

         -- MINING TURTLE HOME ENTER
        [c.x-1 .. ',' .. c.y+1 .. ',' .. c.z-1] = {x = c.x-2, y = c.y+1, z = c.z-1},

         -- MINING TURTLE HOME EXIT
        [c.x-2 .. ',' .. c.y+1 .. ',' .. c.z-1] = {x = c.x-2, y = c.y+1, z = c.z+0},

         -- CHUNKY TURTLE HOME EXIT
        [c.x-2 .. ',' .. c.y+1 .. ',' .. c.z+0] = {x = c.x-2, y = c.y+1, z = c.z+1},

         -- CHUNKY TURTLE HOME ENTER
        [c.x-2 .. ',' .. c.y+1 .. ',' .. c.z+1] = {x = c.x-2, y = c.y+1, z = c.z+2},

        [c.x-2 .. ',' .. c.y+1 .. ',' .. c.z+2] = {x = c.x-1, y = c.y+1, z = c.z+2},
        [c.x-1 .. ',' .. c.y+1 .. ',' .. c.z+2] = {x = c.x+0, y = c.y+1, z = c.z+2},
        [c.x+0 .. ',' .. c.y+1 .. ',' .. c.z+2] = {x = c.x+0, y = c.y+1, z = c.z+1},
        [c.x+0 .. ',' .. c.y+1 .. ',' .. c.z+1] = {x = c.x+1, y = c.y+1, z = c.z+1},

         -- ITEM DROP STATION
        [c.x+1 .. ',' .. c.y+1 .. ',' .. c.z+1] = {x = c.x+2, y = c.y+1, z = c.z+1},

         -- REFUELING STATION
        [c.x+2 .. ',' .. c.y+1 .. ',' .. c.z+1] = {x = c.x+2, y = c.y+1, z = c.z+0},

        [c.x+2 .. ',' .. c.y+1 .. ',' .. c.z+0] = {x = c.x+2, y = c.y+1, z = c.z-1},
        [c.x+2 .. ',' .. c.y+1 .. ',' .. c.z-1] = {x = c.x+1, y = c.y+1, z = c.z-1},
        [c.x+1 .. ',' .. c.y+1 .. ',' .. c.z-1] = {x = c.x+0, y = c.y+1, z = c.z-1},
        [c.x+0 .. ',' .. c.y+1 .. ',' .. c.z-1] = {x = c.x-1, y = c.y+1, z = c.z-1},
    },
}


mining_turtle_locations = {
    -- LOCATIONS THAT ARE SPECIFIC TO
    -- MINING TURTLES

     -- TURTLE HOMES
     --     this is where the first turtle parking
     --     spot will be, and each following will
     --     be in the <increment> direction.
    homes = {x = c.x-3, y = c.y+0, z = c.z-3, increment = 'west'},

     -- THE AREA ENCOMPASSING THE HOME
     -- LINE, AS WELL AS THE PATH TURTLES
     -- TAKE TO GET TO THEIR HOME
    home_area = {
        min_x = -inf,
        max_x = c.x-3,
        min_y = c.y+0,
        max_y = c.y+0,
        min_z = c.z-1,
        max_z = c.z-1
    },

     -- WHERE TURTLES ENTER THE LINE TO
     -- GET TO THEIR HOME
    home_enter = {x = c.x-2, y = c.y+1, z = c.z-1, orientation = 'west'},

     -- WHERE TURTLES EXIT THEIR HOMES
    home_exit = {x = c.x-2, y = c.y+1, z = c.z+0},

     -- WHERE TURTLES WAIT TO BE PAIRED
    waiting_room = {x = c.x-2, y = c.y+0, z = c.z+0},

     -- THE PATH TURTLES WILL TAKE AFTER
     -- PAIRING
    waiting_room_to_mine_enter_route = {
        [c.x-2 .. ',' .. c.y+0 .. ',' .. c.z+0] = {x = c.x-1, y = c.y+0, z = c.z+0},
        [c.x-1 .. ',' .. c.y+0 .. ',' .. c.z+0] = {x = c.x+0, y = c.y+0, z = c.z+0},
    }
}


chunky_turtle_locations = {
    -- LOCATIONS THAT ARE SPECIFIC TO
    -- MINING TURTLES

     -- TURTLE HOMES
     --     this is where the first turtle parking
     --     spot will be, and each following will
     --     be in the <increment> direction.
    homes = {x = c.x-3, y = c.y+0, z = c.z+2, increment = 'west'},

     -- THE AREA ENCOMPASSING THE HOME
     -- LINE, AS WELL AS THE PATH TURTLES
     -- TAKE TO GET TO THEIR HOME
    home_area = {
        min_x = -inf,
        max_x = c.x-3,
        min_y = c.y+0,
        max_y = c.y+0,
        min_z = c.z+2,
        max_z = c.z+2
    },

     -- WHERE TURTLES ENTER THE LINE TO
     -- GET TO THEIR HOME
    home_enter = {x = c.x-2, y = c.y+1, z = c.z+2, orientation = 'west'},

     -- WHERE TURTLES EXIT THEIR HOMES
    home_exit = {x = c.x-2, y = c.y+1, z = c.z+1},

     -- WHERE TURTLES WAIT TO BE PAIRED
    waiting_room = {x = c.x-2, y = c.y+0, z = c.z+1},

     -- THE PATH TURTLES WILL TAKE AFTER
     -- PAIRING
    waiting_room_to_mine_enter_route = {
        [c.x-2 .. ',' .. c.y+0 .. ',' .. c.z+1] = {x = c.x-1, y = c.y+0, z = c.z+1},
        [c.x-1 .. ',' .. c.y+0 .. ',' .. c.z+1] = {x = c.x-1, y = c.y+0, z = c.z+0},
        [c.x-1 .. ',' .. c.y+0 .. ',' .. c.z+0] = {x = c.x+0, y = c.y+0, z = c.z+0},
    }
}


gravitynames = {
    -- ALL BLOCKS AFFECTED BY GRAVITY
    --     if a turtle sees these it will take
    --     extra care to make sure they're delt
    --     with. works at least a lot percent of
    --     the time
    ['minecraft:gravel'] = true,
    ['minecraft:sand'] = true,
}


orenames = {
    -- ALL THE BLOCKS A TURTLE CONSIDERS ORE
    --     a turtle will continue to mine out a
    --     vein until it reaches <vein_max> or
    --     it stops seeing blocks with names in
    --     this list. block names are exact.
    ['BigReactors:YelloriteOre'] = true,
    ['bigreactors:oreyellorite'] = true,
    ['DraconicEvolution:draconiumDust'] = true,
    ['DraconicEvolution:draconiumOre'] = true,
    ['Forestry:apatite'] = true,
    ['Forestry:resources'] = true,
    ['IC2:blockOreCopper'] = true,
    ['IC2:blockOreLead'] = true,
    ['IC2:blockOreTin'] = true,
    ['IC2:blockOreUran'] = true,
    ['ic2:resource'] = true,
    ['ProjRed|Core:projectred.core.part'] = true,
    ['ProjRed|Exploration:projectred.exploration.ore'] = true,
    ['TConstruct:SearedBrick'] = true,
    ['ThermalFoundation:Ore'] = true,
    ['thermalfoundation:ore'] = true,
    ['thermalfoundation:ore_fluid'] = true,
    ['thaumcraft:ore_amber'] = true,
    ['minecraft:coal'] = true,
    ['minecraft:coal_ore'] = true,
    ['minecraft:diamond'] = true,
    ['minecraft:diamond_ore'] = true,
    ['minecraft:dye'] = true,
    ['minecraft:emerald'] = true,
    ['minecraft:emerald_ore'] = true,
    ['minecraft:gold_ore'] = true,
    ['minecraft:iron_ore'] = true,
    ['minecraft:lapis_ore'] = true,
    ['minecraft:redstone'] = true,
    ['minecraft:redstone_ore'] = true,
    ['galacticraftcore:basic_block_core'] = true,
    ['mekanism:oreblock'] = true,
    ['appliedenergistics2:quartz_ore'] = true
}

blocktags = {
    -- ALL BLOCKS WITH ONE OF THESE TAGS A TURTLE CONSIDERS ORE
    --     most mods categorize ores with the forge:ores tag.
    --     this is an easy way to detect all but a few ores,
    --     which don't posess this exact tag (for example certus quartzfrom AE2)
    ['forge:ores'] = true,
    -- adds Certus Quartz and Charged Certus Quartz
    ['forge:ores/certus_quartz'] = true
}

fuelnames = {
    -- ITEMS THE TURTLE CONSIDERS FUEL
    ['minecraft:coal'] = true,
}


---==[ SCREEN ]==---


-- MAXIMUM ZOOM OUT (INVERSE) OF THE
-- MAP SCREEN
monitor_max_zoom_level = 5


-- DEFAULT ZOOM OF THE MAP SCREEN
--     0 is [1 pixel : 1 block]
default_monitor_zoom_level = 0


-- CENTER OF THE MAP SCREEN
--     probably want the mine center
default_monitor_location = {x = c.x, z = c.z}]===],
    ["hub_files/events.lua"] = [===[while true do
    event = {os.pullEvent()}
    if event[1] == 'rednet_message' then
        local sender = event[2]
        local message = event[3]
        local protocol = event[4]
        
        if protocol == 'user_input' then
            table.insert(state.user_input, message)
        
        elseif protocol == 'turtle_report' then
            if not state.turtles[sender] then
                state.turtles[sender] = {id = sender}
            end
            state.turtles[sender].data = message
            state.turtles[sender].last_update = os.clock()
        
        elseif protocol == 'pocket_report' then
            if not state.pockets[sender] then
                state.pockets[sender] = {id = sender}
            end
            state.pockets[sender].data = message
            state.pockets[sender].last_update = os.clock()
            
        elseif protocol == 'update_request' then
            if fs.isDir(message) then
                local update_package = {}
                local queue = {''}
                while #queue > 0 do
                    dir_name = table.remove(queue)
                    path_name = fs.combine(message, dir_name)
                    for _, object_name in pairs(fs.list(path_name)) do
                        sub_dir_name = fs.combine(dir_name, object_name)
                        sub_path_name = fs.combine(message, sub_dir_name)
                        if fs.isDir(sub_path_name) then
                            table.insert(queue, sub_dir_name)
                        else
                            local file = fs.open(sub_path_name, 'r')
                            update_package[sub_dir_name] = file.readAll()
                            file.close()
                        end
                    end
                end
                update_package.hub_id = os.getComputerID()
                rednet.send(sender, update_package, 'update_package')
            end
        end
        
    elseif event[1] == 'monitor_touch' then
        if state.monitor_touches then
            table.insert(state.monitor_touches, {x = event[3], y = event[4]})
        end
    end
end]===],
    ["hub_files/monitor.lua"] = [===[menu_lines = {
    '#   # ##### #   # #####',
    '## ##   #   ##  # #',
    '# # #   #   # # # ###',
    '#   #   #   #  ## #',
    '#   # ##### #   # #',
}

decimals = {
    [0] = {
        '#####',
        '#   #',
        '#   #',
        '#   #',
        '#####',
    },
    [1] = {
        '###  ',
        '  #  ',
        '  #  ',
        '  #  ',
        '#####',
    },
    [2] = {
        '#####',
        '    #',
        '#####',
        '#    ',
        '#####',
    },
    [3] = {
        '#####',
        '    #',
        '#####',
        '    #',
        '#####',
    },
    [4] = {
        '#   #',
        '#   #',
        '#####',
        '    #',
        '    #',
    },
    [5] = {
        '#####',
        '#    ',
        '#####',
        '    #',
        '#####',
    },
    [6] = {
        '#####',
        '#    ',
        '#####',
        '#   #',
        '#####',
    },
    [7] = {
        '#####',
        '    #',
        '    #',
        '    #',
        '    #',
    },
    [8] = {
        '#####',
        '#   #',
        '#####',
        '#   #',
        '#####',
    },
    [9] = {
        '#####',
        '#   #',
        '#####',
        '    #',
        '    #',
    },
}

function debug_print(string)
    term.redirect(monitor.restore_to)
    print(string)
    term.redirect(monitor)
end

function turtle_viewer(turtle_ids)
    term.redirect(monitor)
    
    local selected = 1
    
    while true do
        local turtle_id = turtle_ids[selected]
        local turtle = state.turtles[turtle_id]
        
        -- RESOLVE MONITOR TOUCHES, EITHER BY AFFECTING THE DISPLAY OR INSERTING INTO USER_INPUT TABLE
        while #state.monitor_touches > 0 do
            local monitor_touch = table.remove(state.monitor_touches)
            if monitor_touch.x == elements.left.x and monitor_touch.y == elements.left.y then
                selected = math.max(selected - 1, 1)
            elseif monitor_touch.x == elements.right.x and monitor_touch.y == elements.right.y then
                selected = math.min(selected + 1, #turtle_ids)
            elseif monitor_touch.x == elements.viewer_exit.x and monitor_touch.y == elements.viewer_exit.y then
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elements.turtle_return.x and monitor_touch.y == elements.turtle_return.y then
                table.insert(state.user_input, 'return ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_update.x and monitor_touch.y == elements.turtle_update.y then
                table.insert(state.user_input, 'update ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_reboot.x and monitor_touch.y == elements.turtle_reboot.y then
                table.insert(state.user_input, 'reboot ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_halt.x and monitor_touch.y == elements.turtle_halt.y then
                table.insert(state.user_input, 'halt ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_clear.x and monitor_touch.y == elements.turtle_clear.y then
                table.insert(state.user_input, 'clear ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_reset.x and monitor_touch.y == elements.turtle_reset.y then
                table.insert(state.user_input, 'reset ' .. turtle_id)
            elseif monitor_touch.x == elements.turtle_find.x and monitor_touch.y == elements.turtle_find.y then
                monitor_location.x = turtle.data.location.x
                monitor_location.z = turtle.data.location.z
                monitor_zoom_level = 0
                for level_index, level_and_chance in pairs(config.mine_levels) do
                    if turtle.strip and level_and_chance.level == turtle.strip.y then
                        monitor_level_index = level_index
                        select_mine_level()
                        break
                    end
                end
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elements.turtle_forward.x and monitor_touch.y == elements.turtle_forward.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go forward')
            elseif monitor_touch.x == elements.turtle_back.x and monitor_touch.y == elements.turtle_back.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go back')
            elseif monitor_touch.x == elements.turtle_up.x and monitor_touch.y == elements.turtle_up.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go up')
            elseif monitor_touch.x == elements.turtle_down.x and monitor_touch.y == elements.turtle_down.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go down')
            elseif monitor_touch.x == elements.turtle_left.x and monitor_touch.y == elements.turtle_left.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go left')
            elseif monitor_touch.x == elements.turtle_right.x and monitor_touch.y == elements.turtle_right.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go right')
            elseif turtle.data.turtle_type == 'mining' then
                if monitor_touch.x == elements.turtle_dig_up.x and monitor_touch.y == elements.turtle_dig_up.y then
                    table.insert(state.user_input, 'turtle ' .. turtle_id .. ' digblock up')
                elseif monitor_touch.x == elements.turtle_dig.x and monitor_touch.y == elements.turtle_dig.y then
                    table.insert(state.user_input, 'turtle ' .. turtle_id .. ' digblock forward')
                elseif monitor_touch.x == elements.turtle_dig_down.x and monitor_touch.y == elements.turtle_dig_down.y then
                    table.insert(state.user_input, 'turtle ' .. turtle_id .. ' digblock down')
                end
            end
        end
        
        turtle_id = turtle_ids[selected]
        turtle = state.turtles[turtle_id]
        
        background_color = colors.black
        term.setBackgroundColor(background_color)
        monitor.clear()
        
        if turtle.last_update + config.turtle_timeout < os.clock() then
            term.setCursorPos(elements.turtle_lost.x, elements.turtle_lost.y)
            term.setTextColor(colors.red)
            term.write('CONNECTION LOST')
        end
        
        local x_position = elements.turtle_id.x
        for decimal_string in string.format('%04d', turtle_id):gmatch"." do
            for y_offset, line in pairs(decimals[tonumber(decimal_string)]) do
                term.setCursorPos(x_position, elements.turtle_id.y + y_offset - 1)
                for char in line:gmatch"." do
                    if char == '#' then
                        term.setBackgroundColor(colors.green)
                    else
                        term.setBackgroundColor(colors.black)
                    end
                    term.write(' ')
                end
            end
            x_position = x_position + 6
        end
        
        term.setCursorPos(elements.turtle_face.x + 1, elements.turtle_face.y)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elements.turtle_face.x + 1, elements.turtle_face.y + 1)
        term.setBackgroundColor(colors.yellow)
        term.write(' ')
        term.setBackgroundColor(colors.gray)
        term.write('     ')
        term.setBackgroundColor(colors.yellow)
        term.write(' ')
        term.setCursorPos(elements.turtle_face.x + 1, elements.turtle_face.y + 2)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elements.turtle_face.x + 1, elements.turtle_face.y + 3)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elements.turtle_face.x + 1, elements.turtle_face.y + 4)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        
        if turtle.data.peripheral_right == 'modem' then
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 2)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_right == 'pick' then
            term.setBackgroundColor(colors.cyan)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 2)
            term.write(' ')
            term.setBackgroundColor(colors.brown)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_right == 'chunkLoader' then
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.blue)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 2)
            term.write(' ')
        elseif turtle.data.peripheral_right == 'chunky' then
            term.setBackgroundColor(colors.white)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.red)
            term.setCursorPos(elements.turtle_face.x, elements.turtle_face.y + 2)
            term.write(' ')
        end
        
        if turtle.data.peripheral_left == 'modem' then
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 2)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_left == 'pick' then
            term.setBackgroundColor(colors.cyan)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 2)
            term.write(' ')
            term.setBackgroundColor(colors.brown)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_left == 'chunkLoader' then
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.blue)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 2)
            term.write(' ')
        elseif turtle.data.peripheral_left == 'chunky' then
            term.setBackgroundColor(colors.white)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.red)
            term.setCursorPos(elements.turtle_face.x + 8, elements.turtle_face.y + 2)
            term.write(' ')
        end
        
        term.setBackgroundColor(background_color)
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y)
        term.setTextColor(colors.white)
        term.write('State: ')
        term.setTextColor(colors.green)
        term.write(turtle.state)
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 1)
        term.setTextColor(colors.white)
        term.write('X: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.x)
        end
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 2)
        term.setTextColor(colors.white)
        term.write('Y: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.y)
        end
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 3)
        term.setTextColor(colors.white)
        term.write('Z: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.z)
        end
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 4)
        term.setTextColor(colors.white)
        term.write('Facing: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.orientation)
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 5)
        term.setTextColor(colors.white)
        term.write('Fuel: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.fuel_level)
        
        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 6)
        term.setTextColor(colors.white)
        term.write('Items: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.item_count)
        
--        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 7)
--        term.setTextColor(colors.white)
--        term.write('Dist: ')
--        term.setTextColor(colors.green)
--        term.write(turtle.data.distance)
        
        term.setTextColor(colors.white)
        
        term.setCursorPos(elements.turtle_return.x, elements.turtle_return.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-RETURN')
        
        term.setCursorPos(elements.turtle_update.x, elements.turtle_update.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-UPDATE')
        
        term.setCursorPos(elements.turtle_reboot.x, elements.turtle_reboot.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-REBOOT')
        
        term.setCursorPos(elements.turtle_halt.x, elements.turtle_halt.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-HALT')
        
        term.setCursorPos(elements.turtle_clear.x, elements.turtle_clear.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-CLEAR')
        
        term.setCursorPos(elements.turtle_reset.x, elements.turtle_reset.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-RESET')
        
        term.setCursorPos(elements.turtle_find.x, elements.turtle_find.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-FIND')
        
        term.setCursorPos(elements.turtle_forward.x, elements.turtle_forward.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('^')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-FORWARD')
        
        term.setCursorPos(elements.turtle_back.x, elements.turtle_back.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('V')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-BACK')
        
        term.setCursorPos(elements.turtle_up.x, elements.turtle_up.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('^')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-UP')
        
        term.setCursorPos(elements.turtle_down.x, elements.turtle_down.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('V')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-DOWN')
        
        term.setCursorPos(elements.turtle_left.x, elements.turtle_left.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('<')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-LEFT')
        
        term.setCursorPos(elements.turtle_right.x, elements.turtle_right.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('>')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-RIGHT')
        
        term.setCursorPos(elements.turtle_dig_up.x, elements.turtle_dig_up.y)
        term.setTextColor(colors.white)
        if turtle.data.turtle_type == 'mining' then
            term.setBackgroundColor(colors.green)
        else
            term.setBackgroundColor(colors.gray)
        end
        term.write('^')
        
        term.setCursorPos(elements.turtle_dig.x, elements.turtle_dig.y)
        term.setTextColor(colors.white)
        if turtle.data.turtle_type == 'mining' then
            term.setBackgroundColor(colors.green)
        else
            term.setBackgroundColor(colors.gray)
        end
        term.write('*')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-DIG')
        
        term.setCursorPos(elements.turtle_dig_down.x, elements.turtle_dig_down.y)
        term.setTextColor(colors.white)
        if turtle.data.turtle_type == 'mining' then
            term.setBackgroundColor(colors.green)
        else
            term.setBackgroundColor(colors.gray)
        end
        term.write('v')
        
        term.setTextColor(colors.white)
        if selected == 1 then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.green)
        end
        term.setCursorPos(elements.left.x, elements.left.y)
        term.write('<')
        if selected == #turtle_ids then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.green)
        end
        term.setCursorPos(elements.right.x, elements.right.y)
        term.write('>')
        term.setBackgroundColor(colors.red)
        term.setCursorPos(elements.viewer_exit.x, elements.viewer_exit.y)
        term.write('x')
        
        monitor.setVisible(true)
        monitor.setVisible(false)
        
        sleep(sleep_len)
    end
end


function menu()
    term.redirect(monitor)
    
    while true do
        while #state.monitor_touches > 0 do
            local monitor_touch = table.remove(state.monitor_touches)
            if monitor_touch.x == elements.viewer_exit.x and monitor_touch.y == elements.viewer_exit.y then
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elements.menu_toggle.x and monitor_touch.y == elements.menu_toggle.y then
                if state.on then
                    table.insert(state.user_input, 'off')
                else
                    table.insert(state.user_input, 'on')
                end
            elseif monitor_touch.x == elements.menu_update.x and monitor_touch.y == elements.menu_update.y then
                table.insert(state.user_input, 'update')
            elseif monitor_touch.x == elements.menu_return.x and monitor_touch.y == elements.menu_return.y then
                table.insert(state.user_input, 'return')
            elseif monitor_touch.x == elements.menu_reboot.x and monitor_touch.y == elements.menu_reboot.y then
                table.insert(state.user_input, 'reboot')
            elseif monitor_touch.x == elements.menu_halt.x and monitor_touch.y == elements.menu_halt.y then
                table.insert(state.user_input, 'halt')
            elseif monitor_touch.x == elements.menu_clear.x and monitor_touch.y == elements.menu_clear.y then
                table.insert(state.user_input, 'clear')
            elseif monitor_touch.x == elements.menu_reset.x and monitor_touch.y == elements.menu_reset.y then
                table.insert(state.user_input, 'reset')
            end
        end
        
        term.setBackgroundColor(colors.black)
        monitor.clear()
        
        term.setTextColor(colors.white)
        term.setCursorPos(elements.menu_title.x, elements.menu_title.y)
        term.write('MASTER')
        
        for y_offset, line in pairs(menu_lines) do
            term.setCursorPos(elements.menu_title.x, elements.menu_title.y + y_offset)
            for char in line:gmatch"." do
                if char == '#' then
                    if state.on then
                        term.setBackgroundColor(colors.lime)
                    else
                        term.setBackgroundColor(colors.red)
                    end
                else
                    term.setBackgroundColor(colors.black)
                end
                term.write(' ')
            end
        end
        
        term.write('.lua')
        
        term.setBackgroundColor(colors.red)
        term.setCursorPos(elements.viewer_exit.x, elements.viewer_exit.y)
        term.write('x')
        term.setBackgroundColor(colors.green)
        term.setCursorPos(elements.menu_toggle.x, elements.menu_toggle.y)
        term.write('*')
        term.setCursorPos(elements.menu_return.x, elements.menu_return.y)
        term.write('*')
        term.setCursorPos(elements.menu_update.x, elements.menu_update.y)
        term.write('*')
        term.setCursorPos(elements.menu_reboot.x, elements.menu_reboot.y)
        term.write('*')
        term.setCursorPos(elements.menu_halt.x, elements.menu_halt.y)
        term.write('*')
        term.setCursorPos(elements.menu_clear.x, elements.menu_clear.y)
        term.write('*')
        term.setCursorPos(elements.menu_reset.x, elements.menu_reset.y)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.setCursorPos(elements.menu_toggle.x + 1, elements.menu_toggle.y)
        term.write('-TOGGLE POWER')
        term.setCursorPos(elements.menu_update.x + 1, elements.menu_update.y)
        term.write('-UPDATE')
        term.setCursorPos(elements.menu_return.x + 1, elements.menu_return.y)
        term.write('-RETURN')
        term.setCursorPos(elements.menu_reboot.x + 1, elements.menu_reboot.y)
        term.write('-REBOOT')
        term.setCursorPos(elements.menu_halt.x + 1, elements.menu_halt.y)
        term.write('-HALT')
        term.setCursorPos(elements.menu_clear.x + 1, elements.menu_clear.y)
        term.write('-CLEAR')
        term.setCursorPos(elements.menu_reset.x + 1, elements.menu_reset.y)
        term.write('-RESET')
        
        monitor.setVisible(true)
        monitor.setVisible(false)
        
        sleep(sleep_len)
    end
end


function draw_location(location, color)
    if location then
        local pixel = {
            -- x = monitor_width  - math.floor((location.x - min_location.x) / zoom_factor),
            -- y = monitor_height - math.floor((location.z - min_location.z) / zoom_factor),
            x = math.floor((location.x - min_location.x) / zoom_factor),
            y = math.floor((location.z - min_location.z) / zoom_factor),
        }
        if pixel.x >= 1 and pixel.x <= monitor_width and pixel.y >= 1 and pixel.y <= monitor_height then
            if color then
                paintutils.drawPixel(pixel.x, pixel.y, color)
            end
            return pixel
        end
    end
end
    

function draw_monitor()
    
    term.redirect(monitor)
    term.setBackgroundColor(colors.black)
    monitor.clear()
    
    zoom_factor = math.pow(2, monitor_zoom_level)
    min_location = {
        x = monitor_location.x - math.floor(monitor_width  * zoom_factor / 2) - 1,
        z = monitor_location.z - math.floor(monitor_height * zoom_factor / 2) - 1,
    }
    
    local mined = {}
    local xz
    for x = min_location.x - ((min_location.x - config.locations.mine_enter.x) % config.grid_width), min_location.x + (monitor_width * zoom_factor), config.grid_width do
        for z = min_location.z, min_location.z + (monitor_height * zoom_factor), zoom_factor do
            xz = x .. ',' .. z
            if not mined[xz] then
                if z > config.locations.mine_enter.z then
                    if monitor_level[x] and monitor_level[x].south.z > z then
                        mined[xz] = true
                        draw_location({x = x, z = z}, colors.lightGray)
                    else
                        draw_location({x = x, z = z}, colors.gray)
                    end
                else
                    if monitor_level[x] and monitor_level[x].north.z < z then
                        mined[xz] = true
                        draw_location({x = x, z = z}, colors.lightGray)
                    else
                        draw_location({x = x, z = z}, colors.gray)
                    end
                end
            end
        end
    end
    
    for x = min_location.x, min_location.x + (monitor_width * zoom_factor), zoom_factor do
        if x > monitor_level.main_shaft.west.x and x < monitor_level.main_shaft.east.x then
            draw_location({x = x, z = config.locations.mine_enter.z}, colors.lightGray)
        else
            draw_location({x = x, z = config.locations.mine_enter.z}, colors.gray)
        end
    end
    
    local pixel
    local special = {}
    
    pixel = draw_location(config.locations.mine_exit, colors.blue)
    if pixel then
        special[pixel.x .. ',' .. pixel.y] = colors.blue
    end
    
    pixel = draw_location(config.locations.mine_enter, colors.blue)
    if pixel then
        special[pixel.x .. ',' .. pixel.y] = colors.blue
    end
    
    -- DRAW STRIP ENDINGS
    for name, strip in pairs(monitor_level) do
        if name ~= 'y' then
            for _, strip_end in pairs(strip) do
                if strip_end.turtles then
                    pixel = draw_location(strip_end, colors.green)
                    if pixel then
                        special[pixel.x .. ',' .. pixel.y] = colors.green
                    end
                end
            end
        end
    end
    
    term.setTextColor(colors.black)
    turtles = {}
    local str_pixel
    for _, turtle in pairs(state.turtles) do
        if turtle.data then
            local location = turtle.data.location
            if location and location.x and location.y then
                pixel = draw_location(location)
                if pixel then
                    term.setCursorPos(pixel.x, pixel.y)
                    str_pixel = pixel.x .. ',' .. pixel.y
                    if special[str_pixel] then
                        term.setBackgroundColor(special[str_pixel])
                    elseif turtle.last_update + config.turtle_timeout < os.clock() then
                        term.setBackgroundColor(colors.red)
                    else
                        term.setBackgroundColor(colors.yellow)
                    end
                    if not turtles[str_pixel] then
                        turtles[str_pixel] = {turtle.id}
                        term.write('-')
                    else
                        table.insert(turtles[str_pixel], turtle.id)
                        if #turtles[str_pixel] <= 9 then
                            term.write(#turtles[str_pixel])
                        else
                            term.write('+')
                        end
                    end
                end
            end
        end
    end
    
    for _, pocket in pairs(state.pockets) do
        local location = pocket.data.location
        if location and location.x and location.y then
            pixel = draw_location(location)
            if pixel then
                term.setCursorPos(pixel.x, pixel.y)
                str_pixel = pixel.x .. ',' .. pixel.y
                if pocket.last_update + config.pocket_timeout < os.clock() then
                    term.setBackgroundColor(colors.red)
                else
                    term.setBackgroundColor(colors.green)
                end
                term.write('M')
            end
        end
    end
    
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.green)
    term.setCursorPos(elements.menu.x, elements.menu.y)
    term.write('*')
    term.setCursorPos(elements.all_turtles.x, elements.all_turtles.y)
    term.write('*')
    term.setCursorPos(elements.mining_turtles.x, elements.mining_turtles.y)
    term.write('*')
    term.setCursorPos(elements.center.x, elements.center.y)
    term.write('*')
    term.setCursorPos(elements.up.x, elements.up.y)
    term.write('N')
    term.setCursorPos(elements.down.x, elements.down.y)
    term.write('S')
    term.setCursorPos(elements.left.x, elements.left.y)
    term.write('W')
    term.setCursorPos(elements.right.x, elements.right.y)
    term.write('E')
    term.setCursorPos(elements.level_up.x, elements.level_up.y)
    term.write('+')
    term.setCursorPos(elements.level_down.x, elements.level_down.y)
    term.write('-')
    term.setCursorPos(elements.zoom_in.x, elements.zoom_in.y)
    term.write('+')
    term.setCursorPos(elements.zoom_out.x, elements.zoom_out.y)
    term.write('-')
    term.setBackgroundColor(colors.brown)
    term.setCursorPos(elements.level_indicator.x, elements.level_indicator.y)
    term.write(string.format('LEVEL: %3d', monitor_level.y))
    term.setCursorPos(elements.zoom_indicator.x, elements.zoom_indicator.y)
    term.write('ZOOM: ' .. monitor_zoom_level)
    term.setCursorPos(elements.x_indicator.x, elements.x_indicator.y)
    term.write('X: ' .. monitor_location.x)
    term.setCursorPos(elements.z_indicator.x, elements.z_indicator.y)
    term.write('Z: ' .. monitor_location.z)
    term.setCursorPos(elements.center_indicator.x, elements.center_indicator.y)
    term.write('-CENTER')
    term.setCursorPos(elements.menu_indicator.x, elements.menu_indicator.y)
    term.write('-MENU')
    term.setCursorPos(elements.all_indicator.x, elements.all_indicator.y)
    term.write('ALL-')
    term.setCursorPos(elements.mining_indicator.x, elements.mining_indicator.y)
    term.write('MINING-')
    
    term.redirect(monitor.restore_to)
end


function touch_monitor(monitor_touch)
    if monitor_touch.x == elements.up.x and monitor_touch.y == elements.up.y then
        monitor_location.z = monitor_location.z - zoom_factor
    elseif monitor_touch.x == elements.down.x and monitor_touch.y == elements.down.y then
        monitor_location.z = monitor_location.z + zoom_factor
    elseif monitor_touch.x == elements.left.x and monitor_touch.y == elements.left.y then
        monitor_location.x = monitor_location.x - zoom_factor
    elseif monitor_touch.x == elements.right.x and monitor_touch.y == elements.right.y then
        monitor_location.x = monitor_location.x + zoom_factor
    elseif monitor_touch.x == elements.level_up.x and monitor_touch.y == elements.level_up.y then
        monitor_level_index = math.min(monitor_level_index + 1, #config.mine_levels)
        select_mine_level()
    elseif monitor_touch.x == elements.level_down.x and monitor_touch.y == elements.level_down.y then
        monitor_level_index = math.max(monitor_level_index - 1, 1)
        select_mine_level()
    elseif monitor_touch.x == elements.zoom_in.x and monitor_touch.y == elements.zoom_in.y then
        monitor_zoom_level = math.max(monitor_zoom_level - 1, 0)
    elseif monitor_touch.x == elements.zoom_out.x and monitor_touch.y == elements.zoom_out.y then
        monitor_zoom_level = math.min(monitor_zoom_level + 1, config.monitor_max_zoom_level)
    elseif monitor_touch.x == elements.menu.x and monitor_touch.y == elements.menu.y then
        menu()
    elseif monitor_touch.x == elements.center.x and monitor_touch.y == elements.center.y then
        monitor_location = {x = config.default_monitor_location.x, z = config.default_monitor_location.z}
    elseif monitor_touch.x == elements.all_turtles.x and monitor_touch.y == elements.all_turtles.y then
        local turtle_ids = {}
        for _, turtle in pairs(state.turtles) do
            if turtle.data then
                table.insert(turtle_ids, turtle.id)
            end
        end
        if #turtle_ids then
            turtle_viewer(turtle_ids)
        end
    elseif monitor_touch.x == elements.mining_turtles.x and monitor_touch.y == elements.mining_turtles.y then
        local turtle_ids = {}
        for _, turtle in pairs(state.turtles) do
            if turtle.data and turtle.data.turtle_type == 'mining' then
                table.insert(turtle_ids, turtle.id)
            end
        end
        if #turtle_ids then
            turtle_viewer(turtle_ids)
        end
    else
        local str_pos = monitor_touch.x .. ',' .. monitor_touch.y
        if turtles[str_pos] then
            turtle_viewer(turtles[str_pos])
        end
    end
end


function init_elements()
    elements = {
        up               = {x = math.ceil(monitor_width / 2), y = 1                            },
        down             = {x = math.ceil(monitor_width / 2), y = monitor_height               },
        left             = {x = 1,                            y = math.ceil(monitor_height / 2)},
        right            = {x = monitor_width,                y = math.ceil(monitor_height / 2)},
        level_up         = {x = monitor_width, y =  1},
        level_down       = {x = monitor_width - 11, y =  1},
        level_indicator  = {x = monitor_width - 10, y =  1},
        zoom_in          = {x = monitor_width, y =  2},
        zoom_out         = {x = monitor_width - 8, y = 2},
        zoom_indicator   = {x = monitor_width - 7, y = 2},
        all_turtles      = {x = monitor_width, y = monitor_height-1},
        all_indicator    = {x = monitor_width - 4, y = monitor_height-1},
        mining_turtles   = {x = monitor_width, y = monitor_height},
        mining_indicator = {x = monitor_width - 7, y = monitor_height},
        menu             = {x =  1, y = monitor_height},
        menu_indicator   = {x =  2, y = monitor_height},
        center           = {x =  1, y =  1},
        center_indicator = {x =  2, y =  1},
        x_indicator      = {x =  1, y =  2},
        z_indicator      = {x =  1, y =  3},
        viewer_exit      = {x =  1, y =  1},
        turtle_face      = {x =  5, y =  2},
        turtle_id        = {x = 16, y =  2},
        turtle_lost      = {x = 13, y =  1},
        turtle_data      = {x =  4, y =  8},
        turtle_return    = {x = 26, y =  8},
        turtle_update    = {x = 26, y =  9},
        turtle_reboot    = {x = 26, y = 10},
        turtle_halt      = {x = 26, y = 11},
        turtle_clear     = {x = 26, y = 12},
        turtle_reset     = {x = 26, y = 13},
        turtle_find      = {x = 26, y = 14},
        turtle_forward   = {x = 10, y = 16},
        turtle_back      = {x = 10, y = 18},
        turtle_up        = {x = 23, y = 16},
        turtle_down      = {x = 23, y = 18},
        turtle_left      = {x =  6, y = 17},
        turtle_right     = {x = 14, y = 17},
        turtle_dig_up    = {x = 31, y = 16},
        turtle_dig       = {x = 31, y = 17},
        turtle_dig_down  = {x = 31, y = 18},
        menu_title       = {x =  9, y =  3},
        menu_toggle      = {x = 10, y = 11},
        menu_update      = {x = 10, y = 13},
        menu_return      = {x = 10, y = 14},
        menu_reboot      = {x = 10, y = 15},
        menu_halt        = {x = 10, y = 16},
        menu_clear       = {x = 10, y = 17},
        menu_reset       = {x = 10, y = 18},
    }
end


function select_mine_level()
    monitor_level = state.mine[config.mine_levels[monitor_level_index].level]
end


function step()
    while #state.monitor_touches > 0 do
        touch_monitor(table.remove(state.monitor_touches))
    end
    draw_monitor()
    monitor.setVisible(true)
    monitor.setVisible(false)
    sleep(sleep_len)
end


function main()
    sleep_len = 0.3
    
    local attached = peripheral.find('monitor')
    
    if not attached then
        error('No monitor connected.')
    end
    
    monitor_size = {attached.getSize()}
    monitor_width = monitor_size[1]
    monitor_height = monitor_size[2]
    
    if monitor_width < 29 or monitor_height < 12 then -- Must be at least that big
        return
    end
    
    monitor = window.create(attached, 1, 1, monitor_width, monitor_height)
    monitor.restore_to = term.current()
    monitor.clear()
    monitor.setVisible(false)
    monitor.setCursorPos(1, 1)
    
    monitor_location = {x = config.locations.mine_enter.x, z = config.locations.mine_enter.z}
    monitor_zoom_level = config.default_monitor_zoom_level
    
    init_elements()
    
    while not state.mine do
        sleep(0.5)
    end
    
    monitor_level_index = 1
    select_mine_level()
    
    state.monitor_touches = {}
    while true do
        local status, caught_error = pcall(step)
        if not status then
            term.redirect(monitor.restore_to)
            error(caught_error)
        end
    end
end


main()]===],
    ["hub_files/report.lua"] = [===[-- CONTINUOUSLY BROADCAST STATUS REPORTS
while true do
    
    turtles_parked = 0
    turtle_count = 0
    for _, turtle in pairs(state.turtles) do
        if turtle.state == 'park' then
            turtles_parked = turtles_parked + 1
        end
        turtle_count = turtle_count + 1
    end

    rednet.broadcast({
            on             = state.on,
            turtles_parked = turtles_parked,
            turtle_count   = turtle_count,
        }, 'hub_report')
    
    sleep(0.5)
    
end]===],
    ["hub_files/session_id"] = [===[29.0]===],
    ["hub_files/startup.lua"] = [===[-- SET LABEL
os.setComputerLabel('Hub')

-- INITIALIZE APIS
if fs.exists('/apis') then
    fs.delete('/apis')
end
fs.makeDir('/apis')
fs.copy('/config.lua', '/apis/config')
fs.copy('/state.lua', '/apis/state')
fs.copy('/basics.lua', '/apis/basics')
os.loadAPI('/apis/config')
os.loadAPI('/apis/state')
os.loadAPI('/apis/basics')


-- OPEN REDNET
for _, side in pairs({'back', 'top', 'left', 'right'}) do
    if peripheral.getType(side) == 'modem' then
        rednet.open(side)
        break
    end
end


-- IF UPDATED PRINT "UPDATED"
if fs.exists('/updated') then
    fs.delete('/updated')
    print('UPDATED')
    state.updated = true
end


-- LAUNCH PROGRAMS AS SEPARATE THREADS
multishell.launch({}, '/user.lua')
multishell.launch({}, '/report.lua')
multishell.launch({}, '/monitor.lua')
multishell.launch({}, '/events.lua')
multishell.launch({}, '/whosmineisitanyway.lua')
multishell.setTitle(2, 'user')
multishell.setTitle(3, 'report')
multishell.setTitle(4, 'monitor')
multishell.setTitle(5, 'events')
multishell.setTitle(6, 'whosmine')]===],
    ["hub_files/state.lua"] = [===[user_input = {}
turtles = {}
pockets = {}
homes = {}]===],
    ["hub_files/update"] = [===[os.run({}, '/disk/hub.lua')]===],
    ["hub_files/updated"] = [===[]===],
    ["hub_files/user.lua"] = [===[-- CONTINUOUSLY AWAIT USER INPUT AND PLACE IN TABLE
while true do
    table.insert(state.user_input, read())
end]===],
    ["hub_files/whosmineisitanyway.lua"] = [===[inf = basics.inf
str_xyz = basics.str_xyz


reverse_shift = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}


function load_mine()
    -- LOAD MINE INTO state.mine FROM /mine/<x,z>/ DIRECTORY
    state.mine_dir_path = '/mine/' .. config.locations.mine_enter.x .. ',' .. config.locations.mine_enter.z .. '/'
    state.mine = {}
    
    if not fs.exists(state.mine_dir_path) then
        fs.makeDir(state.mine_dir_path)
    end
    
    if fs.exists(state.mine_dir_path .. 'on') then
        state.on = true
    end
    
    for _, level_and_chance in pairs(config.mine_levels) do
        local level = level_and_chance.level
        state.mine[level] = {y = level}
    
        -- START WITH AT LEAST A MAIN SHAFT
        state.mine[level].main_shaft = {}
        state.mine[level].main_shaft.west = {name = 'main_shaft', x = config.locations.mine_enter.x, y = level, z = config.locations.mine_enter.z, orientation = 'west'}
        state.mine[level].main_shaft.east = {name = 'main_shaft', x = config.locations.mine_enter.x, y = level, z = config.locations.mine_enter.z, orientation = 'east'}
        
        -- FOR EACH STRIP IN /mine/<x,z>/<level>/ PUT INTO MEMORY
        local level_dir_path = state.mine_dir_path .. level .. '/'
        if not fs.exists(level_dir_path) then
            fs.makeDir(level_dir_path)
        else
            for _, file_name in pairs(fs.list(level_dir_path)) do
                if file_name:sub(1, 1) ~= '.' then
                    local file = fs.open(level_dir_path .. file_name, 'r')
                    if file == nil then
                        error('Failed to open file ' .. level_dir_path .. file_name)
                    else
                        if file_name == 'main_shaft' then
                            local xs = string.gmatch(file.readAll(), '[^,]+')
                            state.mine[level].main_shaft = {}
                            state.mine[level].main_shaft.west = {name = 'main_shaft', x = tonumber(xs()), y = level, z = config.locations.mine_enter.z, orientation = 'west'}
                            state.mine[level].main_shaft.east = {name = 'main_shaft', x = tonumber(xs()), y = level, z = config.locations.mine_enter.z, orientation = 'east'}
                        else
                            local zs = string.gmatch(file.readAll(), '[^,]+')
                            local x = tonumber(file_name)
                            state.mine[level][x] = {}
                            state.mine[level][x].north = {name = x, x = x, y = level, z = tonumber(zs()), orientation = 'north'}
                            state.mine[level][x].south = {name = x, x = x, y = level, z = tonumber(zs()), orientation = 'south'}
                        end
                        file.close()
                    end
                end
            end
        end
    end
    
    state.turtles_dir_path = state.mine_dir_path .. 'turtles/'
    
    if not fs.exists(state.turtles_dir_path) then
        fs.makeDir(state.turtles_dir_path)
    end
    
    local turtle_pairs = {}
    
    for _, turtle_id in pairs(fs.list(state.turtles_dir_path)) do
        if turtle_id:sub(1, 1) ~= '.' then
            turtle_id = tonumber(turtle_id)
            local turtle = {id = turtle_id}
            state.turtles[turtle_id] = turtle
            local turtle_dir_path = state.turtles_dir_path .. turtle_id .. '/'
            if fs.exists(turtle_dir_path .. 'strip') then
                local file = fs.open(turtle_dir_path .. 'strip', 'r')
                if file == nil then
                    error('Failed to open file ' .. turtle_dir_path .. 'strip')
                end
                local strip_args = string.gmatch(file.readAll(), '[^,]+')

                local level = tonumber(strip_args())
                local name = strip_args()
                if name ~= 'main_shaft' then
                    name = tonumber(name)
                end
                local orientation = strip_args()

                if state.mine[level] and state.mine[level][name] and state.mine[level][name][orientation] then
                    turtle.strip = state.mine[level][name][orientation]
                    if fs.exists(turtle_dir_path .. 'deployed') then
                        file = fs.open(turtle_dir_path .. 'deployed', 'r')
                        if file == nil then
                            error('Failed to open file ' .. turtle_dir_path .. 'deployed')
                        end
                        turtle.steps_left = tonumber(file.readAll())
                        if not turtle_pairs[turtle.strip] then
                            turtle_pairs[turtle.strip] = {}
                        end
                        table.insert(turtle_pairs[turtle.strip], turtle)
                    end
                end

            end
            if fs.exists(turtle_dir_path .. 'halt') then
                turtle.state = 'halt'
            end
        end
    end
    
    for strip, turtles in pairs(turtle_pairs) do
        if #turtles == 2 then
            strip.turtles = turtles
            turtles[1].pair = turtles[2]
            turtles[2].pair = turtles[1]
        elseif #turtles == 1 and not config.use_chunky_turtles then
            strip.turtles = turtles
        end
    end
end


function write_strip(level, name)
    -- RECORD THE STATE OF A STRIP AT A GIVEN level AND name TO /mine/<center>/<level>/<name>
    local file = fs.open(state.mine_dir_path .. level .. '/' .. name, 'w')
    if name == 'main_shaft' then
        file.write(state.mine[level][name].west.x .. ',' .. state.mine[level][name].east.x)
    else
        file.write(state.mine[level][name].north.z .. ',' .. state.mine[level][name].south.z)
    end
    file.close()
end


function write_turtle_strip(turtle, strip)
    local file = fs.open(state.turtles_dir_path .. turtle.id .. '/strip', 'w')
    file.write(strip.y .. ',' .. strip.name .. ',' .. strip.orientation)
    file.close()
end


function halt(turtle)
    add_task(turtle, {action = 'pass', end_state = 'halt'})
    fs.open(state.turtles_dir_path .. turtle.id .. '/halt', 'w').close()
end


function unhalt(turtle)
    fs.delete(state.turtles_dir_path .. turtle.id .. '/halt', 'w')
end


function update_strip(turtle)
    -- RECORD THAT A STRIP HAS BEEN EXPLORED TO TURTLE'S POSITION
    local strip = turtle.strip
    if strip then
        if strip.orientation == 'north' then
            strip.z = math.min(strip.z, turtle.data.location.z)
        elseif strip.orientation == 'south' then
            strip.z = math.max(strip.z, turtle.data.location.z)
        elseif strip.orientation == 'east' then
            strip.x = math.max(strip.x, turtle.data.location.x)
        elseif strip.orientation == 'west' then
            strip.x = math.min(strip.x, turtle.data.location.x)
        end
        write_strip(strip.y, strip.name)
    end
end


function expand_mine(level, x)
    if not state.mine[level][x] then
        state.mine[level][x] = {}
        state.mine[level][x].north = {name = x, x = x, y = level, z = config.locations.mine_enter.z, orientation = 'north'}
        state.mine[level][x].south = {name = x, x = x, y = level, z = config.locations.mine_enter.z, orientation = 'south'}
        write_strip(level, x)
    end
end


function gen_next_strip()
    local level = get_mining_level()
    state.next_strip = get_closest_free_strip(level)
    if state.next_strip then
        state.min_fuel = (basics.distance(state.next_strip, config.locations.mine_enter) + config.mission_length) * 3
    else
        state.min_fuel = nil
    end
end


function get_closest_free_strip(level)
    local west_x = config.locations.mine_enter.x
    local east_x = config.locations.mine_enter.x
    local offset_x = 0
    local min_x = state.mine[level].main_shaft.west.x
    local max_x = state.mine[level].main_shaft.east.x
    
    local closest_strip
    local distance
    local z_distance
    local min_dist = inf
    
    while west_x >= min_x and east_x <= max_x and offset_x < min_dist do
        for _, x in pairs({west_x, east_x}) do
            for _, z_side in pairs({'north', 'south'}) do
                expand_mine(level, x)
                strip = state.mine[level][x][z_side]
                if not strip.turtles then
                    z_distance = math.abs(strip.z - config.locations.mine_enter.z)
                    distance = z_distance + math.abs(strip.x - config.locations.mine_enter.x)
                    if distance < min_dist then
                        min_dist = distance
                        closest_strip = strip
                    end
                end
            end
        end
        offset_x = offset_x + config.grid_width
        west_x = config.locations.mine_enter.x - offset_x
        east_x = config.locations.mine_enter.x + offset_x
    end
    
    for _, strip in pairs({state.mine[level].main_shaft.west, state.mine[level].main_shaft.east}) do
        if not strip.turtles then
            distance = math.abs(strip.x - config.locations.mine_enter.x)
            if distance <= min_dist then
                min_dist = distance
                closest_strip = strip
            end
        end
    end
    
    return closest_strip
end


function get_mining_level()
    local n = 0
    local r = math.random()
    for _, level_and_chance in pairs(config.mine_levels) do
        n = n + level_and_chance.chance
        if n > r then
            return level_and_chance.level
        end
    end
end


function good_on_fuel(mining_turtle, chunky_turtle)
    local fuel_needed = math.ceil(basics.distance(mining_turtle.data.location, config.locations.mine_exit) * 1.5)
    return (mining_turtle.data.fuel_level == "unlimited" or mining_turtle.data.fuel_level > fuel_needed) and ((not config.use_chunky_turtles) or (chunky_turtle.data.fuel_level == "unlimited" or chunky_turtle.data.fuel_level > fuel_needed))
end


function follow(chunky_turtle)
    add_task(chunky_turtle, {
        action = 'go_to_strip',
        data = {chunky_turtle.strip},
        end_state = 'wait',
    })
end


function go_mine(mining_turtle)
    update_strip(mining_turtle)
    add_task(mining_turtle, {
        action = 'mine_vein',
        data = {mining_turtle.strip.orientation},
    })
    add_task(mining_turtle, {
        action = 'clear_gravity_blocks',
    })
    if config.use_chunky_turtles then
        add_task(mining_turtle, {
            action = 'go_to_strip',
            data = {mining_turtle.strip},
            end_state = 'wait',
            end_function = follow,
            end_function_args = {mining_turtle.pair},
        })
    else
        add_task(mining_turtle, {
            action = 'go_to_strip',
            data = {mining_turtle.strip},
            end_state = 'wait',
        })
    end
    mining_turtle.steps_left = mining_turtle.steps_left - 1
    local file = fs.open(state.turtles_dir_path .. mining_turtle.id .. '/deployed', 'w')
    file.write(mining_turtle.steps_left)
    file.close()
end


function free_turtle(turtle)
    if turtle.pair then
        fs.delete(state.turtles_dir_path .. turtle.id .. '/deployed')
        fs.delete(state.turtles_dir_path .. turtle.pair.id .. '/deployed')
        turtle.pair.pair = nil
        turtle.pair = nil
        turtle.strip.turtles = nil
    end
end


function pair_turtles_finish()
    state.pair_hold = nil
end


function pair_turtles_send(chunky_turtle)
    add_task(chunky_turtle, {
        action = 'go_to_mine_enter',
        end_function = pair_turtles_finish
    })
    
    add_task(chunky_turtle, {
        action = 'go_to_strip',
        data = {chunky_turtle.strip},
        end_state = 'wait',
    })
end


function pair_turtles_begin(turtle1, turtle2)
    local mining_turtle
    local chunky_turtle
    if turtle1.data.turtle_type == 'mining' then
        if turtle2.data.turtle_type ~= 'chunky' then
            error('Incompatable turtles')
        end
        mining_turtle = turtle1
        chunky_turtle = turtle2
    elseif turtle1.data.turtle_type == 'chunky' then
        if turtle2.data.turtle_type ~= 'mining' then
            error('Incompatable turtles')
        end
        chunky_turtle = turtle1
        mining_turtle = turtle2
    end
    
    local strip = state.next_strip
    local level = strip.level
    
    if not strip then
        gen_next_strip()
        add_task(mining_turtle, {action = 'pass', end_state = 'idle'})
        add_task(chunky_turtle, {action = 'pass', end_state = 'idle'})
        return
    end
    
    print('Pairing ' .. mining_turtle.id .. ' and ' .. chunky_turtle.id)
    
    mining_turtle.pair = chunky_turtle
    chunky_turtle.pair = mining_turtle
    
    state.pair_hold = {mining_turtle, chunky_turtle}
        
    mining_turtle.steps_left = config.mission_length
    
    strip.turtles = {mining_turtle, chunky_turtle}
    
    for _, turtle in pairs(strip.turtles) do
        turtle.strip = strip
        write_turtle_strip(turtle, strip)
        add_task(turtle, {action = 'pass', end_state = 'trip'})
    end
    
    fs.open(state.turtles_dir_path .. chunky_turtle.id .. '/deployed', 'w').close()
    local file = fs.open(state.turtles_dir_path .. mining_turtle.id .. '/deployed', 'w')
    file.write(mining_turtle.steps_left)
    file.close()
    
    add_task(mining_turtle, {
        action = 'go_to_mine_enter',
        end_function = pair_turtles_send,
        end_function_args = {chunky_turtle}
    })
    
    add_task(mining_turtle, {
        action = 'go_to_strip',
        data = {mining_turtle.strip},
        end_state = 'wait',
    })
    
    gen_next_strip()
end


function solo_turtle_begin(turtle)
    
    local strip = state.next_strip
    local level = strip.level
    
    if not strip then
        gen_next_strip()
        add_task(turtle, {action = 'pass', end_state = 'idle'})
        return
    end
    
    print('Assigning ' .. turtle.id)
        
    turtle.steps_left = config.mission_length
    
    strip.turtles = {turtle}
    
    for _, turtle in pairs(strip.turtles) do
        turtle.strip = strip
        write_turtle_strip(turtle, strip)
        add_task(turtle, {action = 'pass', end_state = 'trip'})
    end
    
    local file = fs.open(state.turtles_dir_path .. turtle.id .. '/deployed', 'w')
    file.write(turtle.steps_left)
    file.close()
    
    add_task(turtle, {
        action = 'go_to_mine_enter',
    })
    
    add_task(turtle, {
        action = 'go_to_strip',
        data = {turtle.strip},
        end_state = 'wait',
    })
    
    gen_next_strip()
end


function check_pair_fuel(turtle)
    if state.min_fuel then
        if (turtle.data.fuel_level ~= "unlimited" and turtle.data.fuel_level <= state.min_fuel) then
            add_task(turtle, {action = 'prepare', data = {state.min_fuel}})
        else
            add_task(turtle, {action = 'pass', end_state = 'pair'})
        end
    else
        gen_next_strip()
    end
end


function send_turtle_up(turtle)
    if turtle.data.location.y < config.locations.mine_enter.y then
        if turtle.strip then
            
            if turtle.data.turtle_type == 'chunky' and turtle.data.location.y == turtle.strip.y then
                add_task(turtle, {action = 'delay', data={3}})
            end
            
            add_task(turtle, {action = 'go_to_mine_exit', data = {turtle.strip}})
        end
    end
end


function initialize_turtle(turtle)
    local data = {session_id, config}
    
    if turtle.state ~= 'halt' then
        turtle.state = 'lost'
    end
    turtle.task_id = 2
    turtle.tasks = {}
    add_task(turtle, {action = 'initialize', data = data})
end


function add_task(turtle, task)
    if not task.data then
        task.data = {}
    end
    table.insert(turtle.tasks, task)
end


function send_tasks(turtle)
    local task = turtle.tasks[1]
    if task then
        local turtle_data = turtle.data
        if turtle_data.request_id == turtle.task_id and turtle.data.session_id == session_id then
            if turtle_data.success then
                if task.end_state then
                    if turtle.state == 'halt' and task.end_state ~= 'halt' then
                        unhalt(turtle)
                    end
                    turtle.state = task.end_state
                end
                if task.end_function then
                    if task.end_function_args then
                        task.end_function(unpack(task.end_function_args))
                    else
                        task.end_function()
                    end
                end
                table.remove(turtle.tasks, 1)
            end
            turtle.task_id = turtle.task_id + 1
        elseif (not turtle_data.busy) and ((not task.epoch) or (task.epoch > os.clock()) or (task.epoch + config.task_timeout < os.clock())) then
            -- ONLY SEND INSTRUCTION AFTER <config.task_timeout> SECONDS HAVE PASSED
            task.epoch = os.clock()
            print(string.format('Sending %s directive to %d', task.action, turtle.id))
            rednet.send(turtle.id, {
                action = task.action,
                data = task.data,
                request_id = turtle_data.request_id
            }, 'mastermine')
        end
    end
end


function user_input(input)
    -- PROCESS USER INPUT FROM USER_INPUT TABLE
    while #state.user_input > 0 do
        local input = table.remove(state.user_input, 1)
        local next_word = string.gmatch(input, '%S+')
        local command = next_word()
        local turtle_id_string = next_word()
        local turtle_id
        local turtles = {}
        if turtle_id_string and turtle_id_string ~= '*' then
            turtle_id = tonumber(turtle_id_string)
            if state.turtles[turtle_id] then
                turtles = {state.turtles[turtle_id]}
            end
        else
            turtles = state.turtles
        end
        if command == 'turtle' then
            -- SEND COMMAND DIRECTLY TO TURTLE
            local action = next_word()
            local data = {}
            for user_arg in next_word do
                table.insert(data, user_arg)
            end
            for _, turtle in pairs(turtles) do
                halt(turtle)
                add_task(turtle, {
                    action = action,
                    data = data,
                })
            end
        elseif command == 'clear' then
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
            end
        elseif command == 'shutdown' then
            -- REBOOT TURTLE
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                rednet.send(turtle.id, {
                    action = 'shutdown',
                }, 'mastermine')
            end
        elseif command == 'reboot' then
            -- REBOOT TURTLE
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                rednet.send(turtle.id, {
                    action = 'reboot',
                }, 'mastermine')
            end
        elseif command == 'update' then
            -- FEED TURTLE DINNER
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                rednet.send(turtle.id, {
                    action = 'update',
                }, 'mastermine')
            end
        elseif command == 'return' then
            -- BRING TURTLE HOME
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                halt(turtle)
                send_turtle_up(turtle)
                add_task(turtle, {action = 'go_to_home'})
            end
        elseif command == 'halt' then
            -- HALT TURTLE(S)
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                halt(turtle)
            end
        elseif command == 'reset' then
            -- HALT TURTLE(S)
            for _, turtle in pairs(turtles) do
                turtle.tasks = {}
                add_task(turtle, {action = 'pass'})
                add_task(turtle, {action = 'pass', end_state = 'lost'})
            end
        elseif command == 'on' or command == 'go' then
            -- ACTIVATE MINING NETWORK
            if not turtle_id_string then
                for _, turtle in pairs(state.turtles) do
                    turtle.tasks = {}
                    add_task(turtle, {action = 'pass'})
                end
                state.on = true
                fs.open(state.mine_dir_path .. 'on', 'w').close()
            end
        elseif command == 'off' or command == 'stop' then
            -- STANDBY MINING NETWORK
            if not turtle_id_string then
                for _, turtle in pairs(state.turtles) do
                    turtle.tasks = {}
                    add_task(turtle, {action = 'pass'})
                    free_turtle(turtle)
                end
                state.on = nil
                fs.delete(state.mine_dir_path .. 'on')
            end
        elseif command == 'hubshutdown' then
            -- STANDBY MINING NETWORK
            if not turtle_id_string then
                os.shutdown()
            end
        elseif command == 'hubreboot' then
            -- STANDBY MINING NETWORK
            if not turtle_id_string then
                os.reboot()
            end
        elseif command == 'hubupdate' then
            -- STANDBY MINING NETWORK
            if not turtle_id_string then
                os.run({}, '/update')
            end
        elseif command == 'debug' then
            -- DEBUG
        end
    end
end


function command_turtles()
    local turtles_for_pair = {}
    
    for _, turtle in pairs(state.turtles) do
        
        if turtle.data then
        
            if turtle.data.session_id ~= session_id then
                -- BABY TURTLE NEEDS TO LEARN
                if (not turtle.tasks) or (not turtle.tasks[1]) or (not (turtle.tasks[1].action == 'initialize')) then
                    initialize_turtle(turtle)
                end
            end

            if #turtle.tasks > 0 then
                -- TURTLE IS BUSY
                send_tasks(turtle)

            elseif not turtle.data.location then
                -- TURTLE NEEDS A MAP
                add_task(turtle, {action = 'calibrate'})

            elseif turtle.state ~= 'halt' then

                if turtle.state == 'park' then
                    -- TURTLE FOUND PARKING
                    if state.on and (config.use_chunky_turtles or turtle.data.turtle_type == 'mining') then
                        add_task(turtle, {action = 'pass', end_state = 'idle'})
                    end

                elseif not state.on and turtle.state ~= 'idle' then
                    -- TURTLE HAS TO STOP
                    add_task(turtle, {action = 'pass', end_state = 'idle'})

                elseif turtle.state == 'lost' then
                    -- TURTLE IS CONFUSED
                    if turtle.data.location.y < config.locations.mine_enter.y and (turtle.pair or not config.use_chunky_turtles) then
                        add_task(turtle, {action = 'pass', end_state = 'trip'})
                        add_task(turtle, {
                            action = 'go_to_strip',
                            data = {turtle.strip},
                            end_state = 'wait'
                        })
                    else
                        add_task(turtle, {action = 'pass', end_state = 'idle'})
                    end

                elseif turtle.state == 'idle' then
                    -- TURTLE IS BORED
                    free_turtle(turtle)
                    if turtle.data.location.y < config.locations.mine_enter.y then
                        send_turtle_up(turtle)
                    elseif not basics.in_area(turtle.data.location, config.locations.control_room_area) then
                        halt(turtle)
                    elseif turtle.data.item_count > 0 or (turtle.data.fuel_level ~= "unlimited" and turtle.data.fuel_level < config.fuel_per_unit) then
                        add_task(turtle, {action = 'prepare', data = {config.fuel_per_unit}})
                    elseif state.on then
                        add_task(turtle, {
                            action = 'go_to_waiting_room',
                            end_function = check_pair_fuel,
                            end_function_args = {turtle},
                        })
                    else
                        add_task(turtle, {action = 'go_to_home', end_state = 'park'})
                    end

                elseif turtle.state == 'pair' then
                    -- TURTLE NEEDS A FRIEND
                    if config.use_chunky_turtles then
                        if not state.pair_hold then
                            if not turtle.pair then
                                table.insert(turtles_for_pair, turtle)
                            end
                        else
                            if not (state.pair_hold[1].pair and state.pair_hold[2].pair) then
                                state.pair_hold = nil
                            end
                        end
                    else
                        solo_turtle_begin(turtle)
                    end

                elseif turtle.state == 'wait' then
                    -- TURTLE GO DO SOME WORK
                    if turtle.pair then
                        if turtle.data.turtle_type == 'mining' and turtle.pair.state == 'wait' then
                            if turtle.steps_left <= 0 or (turtle.data.empty_slot_count == 0 and turtle.pair.data.empty_slot_count == 0) or not good_on_fuel(turtle, turtle.pair) then
                                add_task(turtle, {action = 'pass', end_state = 'idle'})
                                add_task(turtle.pair, {action = 'pass', end_state = 'idle'})
                            elseif turtle.data.empty_slot_count == 0 then
                                add_task(turtle, {
                                    action = 'dump',
                                    data = {reverse_shift[turtle.strip.orientation]}
                                })
                            else
                                add_task(turtle, {action = 'pass', end_state = 'mine'})
                                add_task(turtle.pair, {action = 'pass', end_state = 'mine'})
                                go_mine(turtle)
                            end
                        end
                    elseif not config.use_chunky_turtles then
                        if turtle.steps_left <= 0 or turtle.data.empty_slot_count == 0 or not good_on_fuel(turtle) then
                            add_task(turtle, {action = 'pass', end_state = 'idle'})
                        else
                            add_task(turtle, {action = 'pass', end_state = 'mine'})
                            go_mine(turtle)
                        end
                    else
                        add_task(turtle, {action = 'pass', end_state = 'idle'})
                    end
                elseif turtle.state == 'mine' then
                    if config.use_chunky_turtles and not turtle.pair then
                        add_task(turtle, {action = 'pass', end_state = 'idle'})
                    end
                end
            end
        end
    end
    if #turtles_for_pair == 2 then
        pair_turtles_begin(turtles_for_pair[1], turtles_for_pair[2])
    end
end


function main()
    -- INCREASE SESSION ID BY ONE
    if fs.exists('/session_id') then
        session_id = tonumber(fs.open('/session_id', 'r').readAll()) + 1
    else
        session_id = 1
    end
    local file = fs.open('/session_id', 'w')
    file.write(session_id)
    file.close()
    
    -- LOAD MINE INTO MEMORY
    load_mine()
    
    -- FIND THE CLOSEST STRIP
    gen_next_strip()
    
    local cycle = 0
    while true do
        print('Cycle: ' .. cycle)
        user_input()         -- PROCESS USER INPUT
        command_turtles()    -- COMMAND TURTLES
        sleep(0.1)           -- DELAY 0.1 SECONDS
        cycle = cycle + 1
    end
end


main()]===],
}

for k, v in pairs(files) do
    local file = fs.open(fs.combine(path, k), 'w')
    file.write(v)
    file.close()
end
