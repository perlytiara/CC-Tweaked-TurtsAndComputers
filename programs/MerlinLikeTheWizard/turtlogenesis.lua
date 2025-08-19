-- MerlinLikeTheWizard

TITLE = {
    '  ##### ## ## ##### ##### ###   #####',
    '  ##### ## ## ##### ##### ###   #####',
    '   ###  ## ## ## ##  ###  ###   ## ##',
    '   ###  ##### ####   ###  ##### #####',
    '   ###  ##### ## ##  ###  ##### #####',
    '',
    '##### ##### #  ## ##### ##### ### #####',
    '##### ##    ## ## ##    ##        ##',
    '##    ####  ##### ####  ##### ### #####',
    '## ## ##    ## ## ##       ## ###    ##',
    '##### ##### ##  # ##### ##### ### #####',
}

-------------------------------------------+

VEIN_MAX = 64
FUEL_BAR = 20
START_FUEL = 640
TRAVEL_FUEL = 1280
TRAVEL_FUEL_MIN = 400
HOUSEKEEP_FREQUENCY = 10

-------------------------------------------+

local pretty = require "cc.pretty"
pprint = pretty.pretty_print

CRAFTING_SLOTS = {1, 2, 3, 5, 6, 7, 9, 10, 11}
NON_CRAFTING_SLOTS = {4, 8, 12, 13, 14, 15, 16}

CRAFTING_RECIPES = {
    ['minecraft:crafting_table'] = {
        'planks', 'planks', nil,
        'planks', 'planks', 
    },
    ['minecraft:stick'] = {
        'planks', nil, nil,
        'planks', 
    },
    ['minecraft:furnace'] = {
        'minecraft:cobblestone', 'minecraft:cobblestone', 'minecraft:cobblestone',
        'minecraft:cobblestone',                     nil, 'minecraft:cobblestone',
        'minecraft:cobblestone', 'minecraft:cobblestone', 'minecraft:cobblestone',
    },
    ['minecraft:chest'] = {
        'planks', 'planks', 'planks', 
        'planks',      nil, 'planks', 
        'planks', 'planks', 'planks', 
    },
    ['minecraft:diamond_pickaxe'] = {
        'minecraft:diamond', 'minecraft:diamond', 'minecraft:diamond',
                        nil,   'minecraft:stick',                 nil,
                        nil,   'minecraft:stick',
    },
    ['minecraft:glass_pane'] = {
        'minecraft:glass', 'minecraft:glass', 'minecraft:glass', 
        'minecraft:glass', 'minecraft:glass', 'minecraft:glass',
    },
    ['minecraft:paper'] = {
        'minecraft:sugar_cane', 'minecraft:sugar_cane', 'minecraft:sugar_cane',
    },
    ['computercraft:disk_drive'] = {
        'minecraft:stone',    'minecraft:stone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:redstone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:redstone', 'minecraft:stone', 
    },
    ['computercraft:turtle_normal'] = {
        'minecraft:iron_ingot',          'minecraft:iron_ingot', 'minecraft:iron_ingot', 
        'minecraft:iron_ingot', 'computercraft:computer_normal', 'minecraft:iron_ingot',  
        'minecraft:iron_ingot',               'minecraft:chest', 'minecraft:iron_ingot', 
    },
    ['computercraft:computer_normal'] = {
        'minecraft:stone',      'minecraft:stone', 'minecraft:stone', 
        'minecraft:stone',   'minecraft:redstone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:glass_pane', 'minecraft:stone', 
    },
    ['computercraft:disk'] = {
        'minecraft:paper', 'minecraft:redstone',
    },
    ['mining_crafty_turtle'] = {
        'minecraft:diamond_pickaxe', 'computercraft:turtle_normal', 'minecraft:crafting_table',
    },
    ['planks'] = {
        'log'
    }
}

CRAFTING_TREE = {
    ['computercraft:turtle_normal'] = {count = 1, components = {
        ['computercraft:computer_normal'] = {count = 1, components = {
            ['minecraft:stone'] = {count = 7, components = {
                ['minecraft:cobblestone'] = {count = 1, subterranean = true},
            }},
            ['minecraft:redstone'] = {count = 1, components = {
                ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
            }},
            ['minecraft:glass_pane'] = {count = 1, components = {
                ['minecraft:glass'] = {count = 6, components = {
                    ['minecraft:sand'] = {count = 1, subterranean = false},
                }},
            }},
        }},
        ['minecraft:iron_ingot'] = {count = 7, components = {
            ['minecraft:raw_iron'] = {count = 1, components = {
                ['minecraft:iron_ore'] = {count = 1, subterranean = true},
            }},
        }},
        ['minecraft:chest'] = {count = 1, components = {
            ['planks'] = {count = 8, components = {
                ['log'] = {count = 0.25, subterranean = false},
            }},
        }},
    }},
    ['minecraft:diamond_pickaxe'] = {count = 1, components = {
        ['minecraft:diamond'] = {count = 3, components = {
            ['minecraft:diamond_ore'] = {count = 1, subterranean = true},
        }},
        ['minecraft:stick'] = {count = 2, components = {
            ['planks'] = {count = 1, components = {
                ['log'] = {count = 0.25, subterranean = false},
            }},
        }},
    }},
    ['minecraft:crafting_table'] = {count = 1, components = {
        ['planks'] = {count = 4, components = {
            ['log'] = {count = 0.25, subterranean = false},
        }},
    }},
    ['computercraft:disk_drive'] = {count = 1, components = {
        ['minecraft:stone'] = {count = 7, components = {
            ['minecraft:cobblestone'] = {count = 1, subterranean = true},
        }},
        ['minecraft:redstone'] = {count = 2, components = {
            ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
        }},
    }},
    ['computercraft:disk'] = {count = 1, components = {
        ['minecraft:redstone'] = {count = 1, components = {
            ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
        }},
        ['minecraft:paper'] = {count = 1, components = {
            ['minecraft:dirt'] = {count = 1, subterranean = false},
            ['minecraft:sugar_cane'] = {count = 1, subterranean = false},
        }},
    }},
    ['minecraft:chest'] = {count = 2, components = {
        ['planks'] = {count = 8, components = {
            ['log'] = {count = 0.25, subterranean = false},
        }},
    }},
    ['minecraft:furnace'] = {count = 3, components = {
        ['minecraft:cobblestone'] = {count = 8, subterranean = true},
    }},
    ['minecraft:coal'] = {count = 16, components = {
        ['minecraft:coal_ore'] = {count = 1, subterranean = true},
    }},
}

ORE_PRIORITY = {
    'minecraft:diamond_ore',
    'minecraft:redstone_ore',
    'minecraft:iron_ore',
    'minecraft:coal_ore',
    'minecraft:cobblestone'
}

ORE_DEPTH = {
    ['minecraft:diamond_ore'] = -57,
    ['minecraft:redstone_ore'] = -57,
    ['minecraft:iron_ore'] = 15,
    ['minecraft:coal_ore'] = 30,
    ['minecraft:cobblestone'] = 15
}

ORE_ITEMS = {
    ['minecraft:deepslate_diamond_ore'] = 'minecraft:diamond_ore',
    ['minecraft:deepslate_redstone_ore'] = 'minecraft:redstone_ore',
    ['minecraft:deepslate_iron_ore'] = 'minecraft:iron_ore',
    ['minecraft:deepslate_coal_ore'] = 'minecraft:coal_ore',
    ['minecraft:deepslate_cobblestone'] = 'minecraft:cobblestone'
}

NEEDED_ITEMS = {}
function flattenTree(tree, items)
    for item_name, item_details in pairs(tree) do
        items[item_name] = true
        if item_details.components then
            flattenTree(item_details.components, items)
        end
    end
end
flattenTree(CRAFTING_TREE, NEEDED_ITEMS)

LOG_ITEMS = {
    ['minecraft:oak_log'] = true,
    ['minecraft:spruce_log'] = true,
    ['minecraft:birch_log'] = true,
    ['minecraft:jungle_log'] = true,
    ['minecraft:acacia_log'] = true,
    ['minecraft:dark_oak_log'] = true,
}

PLANKS_ITEMS = {
    ['minecraft:oak_planks'] = true,
    ['minecraft:spruce_planks'] = true,
    ['minecraft:birch_planks'] = true,
    ['minecraft:jungle_planks'] = true,
    ['minecraft:acacia_planks'] = true,
    ['minecraft:dark_oak_planks'] = true,
}

LEAVES_ITEMS = {
    ['minecraft:oak_leaves'] = true,
    ['minecraft:spruce_leaves'] = true,
    ['minecraft:birch_leaves'] = true,
    ['minecraft:jungle_leaves'] = true,
    ['minecraft:acacia_leaves'] = true,
    ['minecraft:dark_oak_leaves'] = true,
}

BUMPS = {
    north = { 0,  0, -1},
    south = { 0,  0,  1},
    east  = { 1,  0,  0},
    west  = {-1,  0,  0},
}

LEFT_SHIFT = {
    north = 'west',
    south = 'east',
    east  = 'north',
    west  = 'south',
}

RIGHT_SHIFT = {
    north = 'east',
    south = 'west',
    east  = 'south',
    west  = 'north',
}

REVERSE_SHIFT = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}

MOVE = {
    forward = turtle.forward,
    up      = turtle.up,
    down    = turtle.down,
    back    = turtle.back,
    left    = turtle.turnLeft,
    right   = turtle.turnRight
}

DETECT = {
    forward = turtle.detect,
    up      = turtle.detectUp,
    down    = turtle.detectDown
}

INSPECT = {
    forward = turtle.inspect,
    up      = turtle.inspectUp,
    down    = turtle.inspectDown
}

DIG = {
    forward = turtle.dig,
    up      = turtle.digUp,
    down    = turtle.digDown
}

PLACE = {
    forward = turtle.place,
    up      = turtle.placeUp,
    down    = turtle.placeDown
}

ATTACK = {
    forward = turtle.attack,
    up      = turtle.attackUp,
    down    = turtle.attackDown
}

VOWELS = {
    'a', 'a', 'a', 'a', 'a',
    'e', 'e', 'e', 'e', 'e', 'e',
    'i', 'i', 'i',
    'o', 'o', 'o',
    'u', 'u',
    'y',
}
CONSONANTS = {
    'b', 'b', 'b', 'b', 'b', 'b', 'b',
    'c', 'c', 'c', 'c', 'c', 'c', 'c',
    'd', 'd', 'd', 'd', 'd',
    'f', 'f', 'f', 'f', 'f',
    'g', 'g', 'g', 'g',
    'h', 'h', 'h',
    'j',
    'k', 'k',
    'l', 'l', 'l', 'l', 'l',
    'm', 'm', 'm', 'm', 'm', 'm', 'm',
    'n', 'n', 'n', 'n', 'n', 'n', 'n',
    'p', 'p', 'p', 'p', 'p',
    'r', 'r', 'r', 'r', 'r', 'r', 'r',
    's', 's', 's', 's', 's', 's', 's', 's', 's',
    't', 't', 't', 't', 't', 't', 't',
    'v',
    'w',
    'x',
    'y',
    'z', 'z', 'z',
}
DOUBLES = {
    'bl', 'br', 'bw', 
    'cr', 'cl',
    'dr', 'dw',
    'fr', 'fl', 'fw',
    'gr', 'gl', 'gw', 'gh',
    'kr', 'kl', 'kw',
    'mw',
    'ng',
    'pr', 'pl',
    'qu',
    'sr', 'sl', 'sw', 'st', 'sh',
    'tr', 'tl', 'tw', 'th',
    'vr', 'vl',
    'wr',
}
CONS_DOUB = {}
for _, c in pairs(CONSONANTS) do
    table.insert(CONS_DOUB, c)
end
for _, c in pairs(DOUBLES) do
    table.insert(CONS_DOUB, c)
end


function genRandName()
    local name = ''
    local count = math.random(3, 6)

    for i = 0, count - 1 do
        if i % 2 == 1 then
            name = name .. VOWELS[math.random(#VOWELS)]
        else
            if (i == count-1) then
                name = name .. CONSONANTS[math.random(#CONSONANTS)]
            else
                name = name .. CONS_DOUB[math.random(#CONS_DOUB)]
            end
        end
    end

    return string.upper(name:sub(1, 1)) .. name:sub(2, -1)
end


function nameTurtle()
    if not os.getComputerLabel() then
        os.setComputerLabel(genRandName())
    end
end


location = {x = 0, y = 0, z = 0}
orientation = 'north'
calibrated = false


function go(direction, nodig)
    if not nodig then
        if DETECT[direction] then
            if DETECT[direction]() then
                DIG[direction]()
            end
        end
    end
    if not MOVE[direction] then
        return false
    end
    if not MOVE[direction]() then
        if ATTACK[direction] then
            ATTACK[direction]()
        end
        return false
    end
    logMovement(direction)
    return true
end


function goAbsolute(direction)
    while not go(direction) do end
end


function logMovement(direction)
    if direction == 'up' then
        location.y = location.y + 1
    elseif direction == 'down' then
        location.y = location.y - 1
    elseif direction == 'forward' then
        bump = BUMPS[orientation]
        location = {x = location.x + bump[1], y = location.y + bump[2], z = location.z + bump[3]}
    elseif direction == 'back' then
        bump = BUMPS[orientation]
        location = {x = location.x - bump[1], y = location.y - bump[2], z = location.z - bump[3]}
    elseif direction == 'left' then
        orientation = LEFT_SHIFT[orientation]
    elseif direction == 'right' then
        orientation = RIGHT_SHIFT[orientation]
    end
    return true
end


function followRoute(route)
    for step in route:gmatch'.' do
        if step == 'u' then
            goAbsolute('up')
        elseif step == 'f' then
            goAbsolute('forward')
        elseif step == 'd' then
            goAbsolute('down')
        elseif step == 'b' then
            goAbsolute('back')
        elseif step == 'l' then
            goAbsolute('left')
        elseif step == 'r' then
            goAbsolute('right')
        end
    end
    return true
end
                    
                    
function face(new_orientation)
    if orientation == new_orientation then
        return true
    elseif RIGHT_SHIFT[orientation] == new_orientation then
        if not go('right') then return false end
    elseif LEFT_SHIFT[orientation] == new_orientation then
        if not go('left') then return false end
    elseif RIGHT_SHIFT[RIGHT_SHIFT[orientation]] == new_orientation then
        if not go('right') then return false end
        if not go('right') then return false end
    else
        return false
    end
    return true
end


function getAdjacentBlock(direction, loc, ori)
    if not loc then loc = location end
    if not ori then ori = orientation end
    if direction == 'up' then
        return {x = loc.x, y = loc.y + 1, z = loc.z}
    elseif direction == 'down' then
        return {x = loc.x, y = loc.y - 1, z = loc.z}
    elseif direction == 'forward' then
        local bump = BUMPS[ori]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    elseif direction == 'back' then
        local bump = BUMPS[ori]
        return {x = loc.x - bump[1], y = loc.y - bump[2], z = loc.z - bump[3]}
    elseif direction == 'left' then
        local bump = BUMPS[LEFT_SHIFT[ori]]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    elseif direction == 'right' then
        local bump = BUMPS[RIGHT_SHIFT[ori]]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    end
end


function getFromChest(wanted_items)
    local slot = 1
    local unwanted = {}
    local remaining_count = 0
    for _, _ in pairs(wanted_items) do
        remaining_count = remaining_count + 1
    end

    while slot <= 16 and remaining_count > 0 do
        if turtle.getItemCount(slot) == 0 then
            turtle.select(slot)
            if not turtle.suck() then break end
            local item_name = interpretItemName(turtle.getItemDetail().name)
            local wanted = false

            if wanted_items[item_name] then
                remaining_count = remaining_count - 1
            else
                table.insert(unwanted, slot)
            end
        end
        slot = slot + 1
    end

    for _, unwanted_slot in pairs(unwanted) do
        turtle.select(unwanted_slot)
        turtle.drop()
    end

    if remaining_count > 0 then
        return nil
    end

    return true
end


function itemsLackedToCraft(craft_item_name, count)
    craft_item_name = interpretItemName(craft_item_name)
    local items = itemsBeared(true)
    local recipe = CRAFTING_RECIPES[craft_item_name]

    local lacked = {}

    for _, item_name in pairs(recipe) do
        for i = 1, count do
            if items[item_name] then
                if items[item_name].count <= 1 then
                    items[item_name] = nil
                else
                    items[item_name].count = items[item_name].count - 1
                end
            else
                if lacked[item_name] then
                    lacked[item_name] = lacked[item_name] + 1
                else
                    lacked[item_name] = 1
                end
            end
        end
    end

    return lacked
end


function craft(craft_item_name, count)
    craft_item_name = interpretItemName(craft_item_name)
    if not count then count = 1 end

    local recipe = CRAFTING_RECIPES[craft_item_name]
    local required_items = {}

    for i, item_name in pairs(recipe) do
        if required_items[item_name] then
            required_items[item_name] = required_items[item_name] + count
        else
            required_items[item_name] = count
        end
    end

    -- Check that the correct items are being used
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if not required_items[name] then
                error('Item "' .. name .. '" not used in recipe for "' .. craft_item_name .. '"')
            end
            if item.count < required_items[name] then
                error('Not enough "' .. name .. '" in stack as per recipe')
            end
        end
    end

    -- Move all items out of the crafting area
    for _, stack_slot in pairs(CRAFTING_SLOTS) do
        if turtle.getItemDetail(stack_slot) then
            turtle.select(stack_slot)
            for _, tranfer_slot in pairs(NON_CRAFTING_SLOTS) do
                if not turtle.getItemDetail(tranfer_slot) then
                    turtle.transferTo(tranfer_slot)
                    break
                end
            end
            if turtle.getItemDetail(stack_slot) then
                error('Too many stacks (crafting recipes with more than 7 unique ingredients not supported)')
            end
        end
    end

    -- Move items back into the crafting area and into the correct positions
    for _, stack_slot in pairs(NON_CRAFTING_SLOTS) do
        local item = turtle.getItemDetail(stack_slot)
        if item then
            local name = interpretItemName(item.name)

            local place_slots = {}
            for i, item_name in pairs(recipe) do
                if item_name == name then
                    table.insert(place_slots, CRAFTING_SLOTS[i])
                end
            end

            for i, place_slot in pairs(place_slots) do
                if i == 1 then
                    turtle.select(stack_slot)
                    turtle.transferTo(place_slot)
                else
                    turtle.select(place_slots[1])
                    turtle.transferTo(place_slot, count)
                end
            end
        end
    end

    -- Craft!
    if not turtle.craft(count) then
        error('Crafting failed')
    end
end


function craftAsNeeded(craft_item_name, count, original_items)
    craft_item_name = interpretItemName(craft_item_name)
    local needed_count = count
    local beared = original_items[craft_item_name]
    if beared then
        needed_count = count - beared.count
    end

    if needed_count > 0 then
        local recipe = CRAFTING_RECIPES[craft_item_name]
        local required_items = {}
        for _, item_name in pairs(recipe) do
            required_items[interpretItemName(item_name)] = true
        end

        dumpExcept(required_items)

        if not getFromChest(itemsLackedToCraft(craft_item_name, count)) then
            error('Needed items not found in chest')
        end

        itemsBeared(true)

        craft(craft_item_name, needed_count)
    end

    if beared then
        getFromChest({[craft_item_name] = true})
        itemsBeared(true)
    end
end


function itemsBeared(drop)
    local item_data = {}

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if NEEDED_ITEMS[name] then
                if not item_data[name] then
                    item_data[name] = {count = item.count, slot = slot}
                elseif drop then
                    turtle.select(slot)
                    if (item_data[name].count < 64) then
                        turtle.transferTo(item_data[name].slot)
                    end
                    if (item_data[name].count < turtle.getItemCount(slot)) then
                        turtle.select(item_data[name].slot)
                        item_data[name] = {count = item.count, slot = slot}
                    end
                    turtle.dropDown()
                end
            elseif drop then
                turtle.select(slot)
                turtle.dropDown()
            end
        end
    end

    turtle.select(1)
    return item_data
end


function itemsLacked(subterranean, item_data, tree, lacked, count)
    if item_data == nil then item_data = itemsBeared() end
    if tree == nil then tree = CRAFTING_TREE end
    if lacked == nil then lacked = {} end
    if count == nil then count = 1 end

    for item_name, item_details in pairs(tree) do

        local need_count = count * item_details.count
        local bear_count = 0
        if item_data[item_name] then
            bear_count = item_data[item_name].count
        end
        local lack_count = need_count - bear_count

        if lack_count >= 0 then
            item_data[item_name] = nil
            if lack_count > 0 then
                if item_details.components then
                    itemsLacked(subterranean, item_data, item_details.components, lacked, lack_count)
                elseif subterranean == nil or subterranean == item_details.subterranean then
                    if lacked[item_name] then
                        lacked[item_name] = lacked[item_name] + lack_count
                    else
                        lacked[item_name] = lack_count
                    end
                end
            end
        else
            item_data[item_name].count = item_data[item_name].count - need_count
        end
    end

    return lacked
end


function calibrate()
    if not calibrated then
        print('Tunneling down to calibrate height')
        while ({INSPECT.down()})[2].name ~= 'minecraft:bedrock' do
            go('down')
        end
        location.y = 10
        location.y = -59
        calibrated = true
    end
end


function atDepth(depth)
    return location.y == depth
end


function travelToDepth(depth)
    calibrate()
    while location.y > depth do
        if ({INSPECT.down()})[2].name == 'minecraft:bedrock' then
            location.y = math.min(location.y, -59)
            break
        end
        goAbsolute('down')
    end
    while location.y < depth do
        goAbsolute('up')
    end
end


function mineVein(subterranean, skip_return, always_mine)
    if not always_mine then always_mine = {} end
    
    -- Log starting location
    local start = strXYZ(location, orientation)
    local start_orientation = orientation

    -- Begin block map
    local valid = {}
    local ores = {}
    valid[strXYZ(location)] = true
    valid[strXYZ(getAdjacentBlock('back'))] = false
    local ore_found = false
    for i = 1, VEIN_MAX do

        -- Get item types that are still lacking
        local lacking = itemsLacked(subterranean)
        for name, _ in pairs(always_mine) do
            if not lacking[name] then
                lacking[name] = 1
            end
        end

        -- Scan adjacent
        local scan_items = scan(valid, ores, lacking)

        -- Do special case 'leaves' thing (for finding logs easier)
        if scan_items['log'] and always_mine['leaves'] then
            always_mine['leaves'] = nil
            lacking['leaves'] = nil
            valid = {}
            ores = {}
            valid[strXYZ(location)] = true
            local s = scan(valid, ores, lacking)
        end

        -- Search for nearest ore
        local route = fastestRoute(valid, ores, location, orientation)

        -- Check if there is one
        if not route then
            break
        end

        -- Retrieve ore
        turtle.select(1)
        if not followRoute(route) then
            face(start_orientation)
            return false
        end
        ores[strXYZ(location)] = nil

    end

    -- Return to start
    if skip_return then
        face(start_orientation)
    else
        followRoute(fastestRoute(valid, {[start] = true}, location, orientation))
    end
    
    return true
end


function scan(valid, ores, ore_names)
    local checked_left  = false
    local checked_right = false

    local found_ore_names = {}
    
    local f = strXYZ(getAdjacentBlock('forward'))
    local u = strXYZ(getAdjacentBlock('up'))
    local d = strXYZ(getAdjacentBlock('down'))
    local l = strXYZ(getAdjacentBlock('left'))
    local r = strXYZ(getAdjacentBlock('right'))
    local b = strXYZ(getAdjacentBlock('back'))
    
    if not valid[f] and valid[f] ~= false then
        valid[f] = detectOre('forward', ore_names)
        ores[f] = valid[f]
        if ores[f] then found_ore_names[ores[f]] = true end
    end
    if not valid[u] and valid[u] ~= false then
        valid[u] = detectOre('up', ore_names)
        ores[u] = valid[u]
        if ores[u] then found_ore_names[ores[u]] = true end
    end
    if not valid[d] and valid[d] ~= false then
        valid[d] = detectOre('down', ore_names)
        ores[d] = valid[d]
        if ores[d] then found_ore_names[ores[d]] = true end
    end
    if not valid[l] and valid[l] ~= false then
        go('left')
        checked_left = true
        valid[l] = detectOre('forward', ore_names)
        ores[l] = valid[l]
        if ores[l] then found_ore_names[ores[l]] = true end
    end
    if not valid[r] and valid[r] ~= false then
        go('right')
        if checked_left then
            go('right')
        end
        checked_right = true
        valid[r] = detectOre('forward', ore_names)
        ores[r] = valid[r]
        if ores[r] then found_ore_names[ores[r]] = true end
    end
    if not valid[b] and valid[b] ~= false then
        if checked_right then
            go('right')
        elseif checked_left then
            go('left')
        else
            go('right')
            go('right')
        end
        valid[b] = detectOre('forward', ore_names)
        ores[b] = valid[b]
        if ores[b] then found_ore_names[ores[b]] = true end
    end

    return found_ore_names
end


function detectOre(direction, ore_names)
    local _, block = INSPECT[direction]()
    local name = interpretItemName(block.name)
    if ore_names[name] then
        return name
    end
    return false
end


function fastestRoute(area, end_locations, loc, ori)
    local queue = {}
    local explored = {}
    table.insert(queue,
        {
            coords = {x = loc.x, y = loc.y, z = loc.z},
            facing = ori,
            path = '',
        }
    )
    explored[strXYZ(loc, ori)] = true

    while #queue > 0 do
        local node = table.remove(queue, 1)
        if end_locations[strXYZ(node.coords)] or end_locations[strXYZ(node.coords, node.facing)] then
            return node.path
        end
        for _, step in pairs({
                {coords = node.coords,                                           facing = LEFT_SHIFT[node.facing],  path = node.path .. 'l'},
                {coords = node.coords,                                           facing = RIGHT_SHIFT[node.facing], path = node.path .. 'r'},
                {coords = getAdjacentBlock('forward', node.coords, node.facing), facing = node.facing,              path = node.path .. 'f'},
                {coords = getAdjacentBlock('up', node.coords, node.facing),      facing = node.facing,              path = node.path .. 'u'},
                {coords = getAdjacentBlock('down', node.coords, node.facing),    facing = node.facing,              path = node.path .. 'd'},
                }) do
            explore_string = strXYZ(step.coords, step.facing)
            if not explored[explore_string] and (not area or area[strXYZ(step.coords)]) then
                explored[explore_string] = true
                table.insert(queue, step)
            end
        end
    end
end


function strXYZ(coords, facing)
    if facing then
        return coords.x .. ',' .. coords.y .. ',' .. coords.z .. ':' .. facing
    else
        return coords.x .. ',' .. coords.y .. ',' .. coords.z
    end
end


function interpretItemName(item_name)
    if LOG_ITEMS[item_name] then
        return 'log'
    elseif PLANKS_ITEMS[item_name] then
        return 'planks'
    elseif LEAVES_ITEMS[item_name] then
        return 'leaves'
    elseif ORE_ITEMS[item_name] then
        return ORE_ITEMS[item_name]
    else
        return item_name
    end
end


refuel_max = false
function smartRefuel()
    if refuel_max then
        if refuelTo(TRAVEL_FUEL) then
            refuel_max = false
            return true
        end
    else
        if refuelTo(TRAVEL_FUEL_MIN) then
            return true
        else
            refuel_max = true
        end
    end
    return false
end


function refuelTo(target_level)
    local lacked_coal = math.ceil((target_level - turtle.getFuelLevel()) / 80)
    if lacked_coal <= 0 then return true end

    for slot = 1, 16 do
        local item_details = turtle.getItemDetail(slot)
        if item_details and item_details.name == 'minecraft:coal' then
            turtle.select(slot)
            turtle.refuel(lacked_coal)
            lacked_coal = math.ceil((target_level - turtle.getFuelLevel()) / 80)
            if lacked_coal <= 0 then return true end
        end
    end

    return false
end


SAND_IGNORE = {['minecraft:water'] = true}
REGULAR_IGNORE = {['minecraft:grass'] = true, ['minecraft:tall_grass'] = true}
function is_trace_block(direction, lacked)
    local is_block, block_data = INSPECT[direction]()
    if not is_block then return false end
    return not (REGULAR_IGNORE[block_data.name] or (lacked['minecraft:sand'] and SAND_IGNORE[block_data.name]))
end


function traceStep(lacked)
    lacked = lacked or {}

    local is_block_forward = is_trace_block('forward', lacked)
    local is_block_down = is_trace_block('down', lacked)

    if is_block_forward then
        go('up')
        is_block_forward = is_trace_block('forward', lacked)
        if not is_block_forward then
            go('forward')
        end
    elseif is_block_down then
        go('forward')
    else
        go('down')
    end
end


function explore()
    print("Exploring the surface for resources")
    local lacked = itemsLacked(false)
    local i = 0
    local refuelGood = true
    while next(lacked) ~= nil and refuelGood do
        traceStep(lacked)

        local is_block_forward, data_block_forward = INSPECT.forward()
        local is_block_down, data_block_down = INSPECT.down()
        local is_block_up, data_block_up = INSPECT.up()

        local block_found =          (is_block_forward and lacked[interpretItemName(data_block_forward.name)])
        block_found = block_found or (is_block_down    and lacked[interpretItemName(data_block_down.name)])
        block_found = block_found or (is_block_up      and lacked[interpretItemName(data_block_up.name)])

        if block_found then
            if is_block_forward and data_block_forward.name == 'minecraft:sugar_cane' then
                while is_block_forward and data_block_forward.name == 'minecraft:sugar_cane' do
                    go('up')
                    is_block_forward, data_block_forward = INSPECT.forward()
                end
                go('forward')
            end
            if lacked['log'] then
                mineVein(false, true, {['leaves'] = true})
            else
                mineVein(false, true)
            end
        end

        lacked = itemsLacked(false)
        if lacked['log'] then
            lacked['leaves'] = true
        end
        if next(lacked) == nil or i >= HOUSEKEEP_FREQUENCY then
            i = 0
            refuelGood = smartRefuel()
            lacked = itemsLacked(false, itemsBeared(true))
        else
            i = i + 1
        end
    end
end


function mine()
    local lacked = itemsLacked(true)
    local refuelGood = smartRefuel()
    if not refuelGood then
        lacked['minecraft:coal_ore'] = true
    end

    local i = 0
    while next(lacked) ~= nil or not refuelGood do
        while ({INSPECT.forward()})[2].name == 'minecraft:bedrock' do
            goAbsolute('up')
            location.y = -59
        end

        if not refuelGood then
            if not atDepth(ORE_DEPTH['minecraft:coal_ore']) then
                print("Traveling to y=" .. ORE_DEPTH['minecraft:coal_ore'] .. " to refuel")
                travelToDepth(ORE_DEPTH['minecraft:coal_ore'])
            end
        else
            for _, ore_name in pairs(ORE_PRIORITY) do
                if lacked[ore_name] then
                    if not atDepth(ORE_DEPTH[ore_name]) then
                        print("Traveling to y=" .. ORE_DEPTH[ore_name] .. " to find " .. ore_name)
                        travelToDepth(ORE_DEPTH[ore_name])
                    end
                    break
                end
            end
        end

        lacked = itemsLacked(true)
        if detectOre('up', lacked) or detectOre('forward', lacked) or detectOre('down', lacked) then
            itemsBeared(true)
            mineVein(true, false, {['minecraft:diamond_ore'] = true})
        end
        go('forward')

        if next(lacked) == nil or i >= HOUSEKEEP_FREQUENCY then
            i = 0
            lacked = itemsLacked(true, itemsBeared(true))
            refuelGood = smartRefuel()
            if not refuelGood then
                lacked['minecraft:coal_ore'] = true
            end
        else
            i = i + 1
        end
    end
end


function createFarm()
    print('Creating sugar cane farm')
    local items = itemsBeared(true)
    local is_block_down, data_block_down = INSPECT.down()
    local is_block_forward = INSPECT.forward()

    while is_block_forward or not (is_block_down and data_block_down.name == 'minecraft:water') do
        traceStep()
        is_block_down, data_block_down = INSPECT.down()
        is_block_forward = INSPECT.forward()
    end

    goAbsolute('forward')
    selectItem('minecraft:dirt')
    DIG.down()
    PLACE.down()
    goAbsolute('up')
    selectItem('minecraft:sugar_cane')
    PLACE.down()
    goAbsolute('up')
end


function dumpExcept(exceptions)
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if not exceptions[name] then
                turtle.select(slot)
                turtle.drop()
            end
        end
    end
end


function destroy(item_name)
    if selectItem(item_name) then
        turtle.dropDown()
    end
end


function selectItem(item_name)
    local items = itemsBeared()
    if not items[interpretItemName(item_name)] then
        return false
    end
    turtle.select(items[interpretItemName(item_name)].slot)
    return true
end


function genesis()
    print("Items collected, begining genesis process")

    local original_items = itemsBeared(true)
    local items = itemsBeared(true)

    -- Make sugar cane farm if needed
    local sugar_needed = 5 - original_items['minecraft:sugar_cane'].count
    if original_items['computercraft:disk'] or original_items['minecraft:paper'] then
        sugar_needed = math.max(0, sugar_needed - 3)
    end
    if sugar_needed > 0 then
        createFarm()
    end

    -- Place chest
    print('Placing proxy chest')
    destroy('minecraft:dirt')
    items = itemsBeared(true)
    selectItem('minecraft:chest')
    DIG.forward()
    PLACE.forward()

    -- Craft furnaces and collect smelting items
    print('Creating smeltery')
    dumpExcept({['minecraft:cobblestone'] = true})
    craftAsNeeded('minecraft:furnace', 3, original_items)
    getFromChest({['minecraft:coal'] = true, ['minecraft:sand'] = true, ['minecraft:raw_iron'] = true})
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    goAbsolute('right')

    -- Place furnaces
    for i = 1, 3 do
        items = itemsBeared(true)
        selectItem('minecraft:furnace')
        DIG.up()
        PLACE.up()
        selectItem('minecraft:coal')
        turtle.dropUp(1)
        if i == 2 then
            turtle.dropUp(1)
        end
        goAbsolute('forward')
    end

    -- Place items in furnaces
    print('Smelting')
    goAbsolute('up')
    goAbsolute('left')
    goAbsolute('up')
    goAbsolute('left')
    goAbsolute('forward')
    if selectItem('minecraft:sand') then
        turtle.dropDown()
    end
    goAbsolute('forward')
    if selectItem('minecraft:cobblestone') then
        turtle.dropDown()
    end
    goAbsolute('forward')
    if selectItem('minecraft:raw_iron') then
        turtle.dropDown()
    end
    goAbsolute('forward')
    goAbsolute('down')
    goAbsolute('right')
    goAbsolute('down')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('forward')
    goAbsolute('left')
    items = itemsBeared(true)

    -- Collect sugar cane if needed
    print('Collecting all necessary sugar cane')
    for i = 1, sugar_needed do
        while not INSPECT.down() do
            sleep(1)
        end
        DIG.down()
    end
    if sugar_needed > 0 then
        goAbsolute('down')
        goAbsolute('down')
        DIG.down()
        goAbsolute('up')
        goAbsolute('up')
        destroy('minecraft:dirt')
    end

    -- Collect furnace contents when ready
    print('Collecting furnace contents')
    dumpExcept({})
    turtle.select(1)
    while true do
        turtle.suckUp()
        if turtle.getItemCount() >= 14 then
            break
        end
        sleep(1)
    end
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    goAbsolute('up')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('forward')
    goAbsolute('left')
    goAbsolute('down')
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    destroy('minecraft:sand')
    destroy('minecraft:iron_ore')
    destroy('minecraft:cobblestone')
    destroy('minecraft:furnace')

    -- Do crafting
    doCrafting(original_items)

    -- Grab final items
    dumpExcept({})
    local items_aquired = getFromChest({
        ['computercraft:turtle_normal'] = true,
        ['computercraft:disk_drive'] = true,
        ['computercraft:disk'] = true,
        ['minecraft:coal'] = true,
        ['minecraft:sugar_cane'] = true,
        ['minecraft:chest'] = true,
    })
    if not items_aquired then
        error('Something went wrong in the crafting process')
    end

    -- Place disk drive
    print('Tranferring contents of brain')
    goAbsolute('left')
    selectItem('computercraft:disk_drive')
    while not PLACE.forward() do
        DIG.forward()
    end
    selectItem('computercraft:disk')
    turtle.drop()
    populateDisk()

    -- Place turtle
    print('Creating turtle')
    goAbsolute('up')
    goAbsolute('forward')
    goAbsolute('forward')
    selectItem('computercraft:turtle_normal')
    while not PLACE.down() do
        DIG.down()
    end
    selectItem('minecraft:chest')
    turtle.dropDown(1)
    selectItem('minecraft:sugar_cane')
    turtle.dropDown(1)
    selectItem('minecraft:coal')
    turtle.dropDown(16)

    -- Give life
    print('Giving life')
    peripheral.call('bottom', 'turnOn')

    -- Pack up
    print('Packing up')
    goAbsolute('right')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('down')
    goAbsolute('forward')
    goAbsolute('left')
    goAbsolute('forward')

end


function doCrafting(original_items)
    print('Do crafting of all necessary items')

    -- Craft turtle
    local chests_lacked = math.max(0, 3 - original_items['minecraft:chest'].count)
    if chests_lacked > 0 then
        craftAsNeeded('planks', chests_lacked * 2, original_items)
        craftAsNeeded('minecraft:chest', chests_lacked, {})
        destroy('planks')
    end
    craftAsNeeded('minecraft:glass_pane', 1, original_items)
    destroy('minecraft:glass')
    craftAsNeeded('computercraft:computer_normal', 1, {})
    craftAsNeeded('computercraft:turtle_normal', 1, {})
    destroy('minecraft:iron_ingot')
    if not (original_items['minecraft:stick'] and original_items['minecraft:stick'].count >= 2) then
        craftAsNeeded('planks', 1, original_items)
        craftAsNeeded('minecraft:stick', 1, {})
        destroy('planks')
    end
    craftAsNeeded('minecraft:diamond_pickaxe', 1, {})
    destroy('minecraft:stick')
    if not original_items['minecraft:crafting_table'] then
        craftAsNeeded('planks', 1, original_items)
        craftAsNeeded('minecraft:crafting_table', 1, {})
    end
    craftAsNeeded('mining_crafty_turtle', 1, {})

    -- Craft disk
    craftAsNeeded('computercraft:disk_drive', 1, original_items)
    if not original_items['computercraft:disk'] then
        craftAsNeeded('minecraft:paper', 1, original_items)
        craftAsNeeded('computercraft:disk', 1, {})
        destroy('minecraft:paper')
    end

end


function main()
    while true do
        local refueled = smartRefuel()
        local need_subterranian_items = next(itemsLacked(true)) ~= nil

        if not refueled or need_subterranian_items then
            -- Items are needed from underground
            mine()
        else
            local need_surface_items = next(itemsLacked(false)) ~= nil
            if need_surface_items then
                -- Items are needed from surface
                explore()
            else
                -- Items are collected
                genesis()
            end
        end
    end
end


function manualChest()
    print('\nPlease insert...')
    print('1 Chest [ ]     1 Sugar Cane [ ]')
    sleep(0.5)

    while true do
        local aquired = 0
        for slot = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and item.name == 'minecraft:chest' then
                aquired = bit32.bor(aquired, 1)
            end
            if item and item.name == 'minecraft:sugar_cane' then
                aquired = bit32.bor(aquired, 2)
            end
        end
        term.setCursorPos(10, 6)
        if bit32.band(aquired, 1) ~= 0 then
            term.write('x')
        else
            term.write(' ')
        end
        term.setCursorPos(31, 6)
        if bit32.band(aquired, 2) ~= 0 then
            term.write('x')
        else
            term.write(' ')
        end
        if aquired == 3 then
            return
        end
        sleep(0.5)
    end

end


function manualRefuel(desired_level)
    print('Please insert coal...')

    local cursor_x, cursor_y = term.getCursorPos()
    local current_level = turtle.getFuelLevel()
    local slot = 1

    printFuelBar(cursor_y, current_level, desired_level)

    while current_level < desired_level do

        for i = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and item.name == 'minecraft:coal' then
                turtle.select(slot)
                if turtle.refuel(5) then break end
            end
            slot = (slot % 16) + 1
        end

        current_level = turtle.getFuelLevel()
        printFuelBar(cursor_y, current_level, desired_level)
        sleep(0)

    end

    sleep(1)
    print('\nFueling complete.')
end


function printFuelBar(cursor_y, current_level, desired_level)
    term.setCursorPos(1, cursor_y)
    local progress = math.min(math.floor(FUEL_BAR * current_level / desired_level), FUEL_BAR)
    term.write('[')
    for i = 1, progress do
        term.write('+')
    end
    for i = 1, FUEL_BAR - progress do
        term.write('-')
    end
    term.write('] ')
    term.write(tostring(current_level))
    term.write('/')
    term.write(tostring(desired_level))
end


function printTitle()
    for y_offset, line in pairs(TITLE) do
        term.setCursorPos(1, y_offset)
        for char in line:gmatch"." do
            if char == '#' then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
            end
            term.write(' ')
        end
    end
    term.setBackgroundColor(colors.black)
end


function userInit()

    term.clear()
    printTitle()
    print('\n      press return to continue...')
    read()

    term.clear()
    term.setCursorPos(1, 1)
    manualRefuel(START_FUEL)

    sleep(1)
    manualChest()

    sleep(1)
    print('\nTurtle preparation complete.')
    sleep(1)
    print('\nFinal confirmation...')
    sleep(0.5)
    print('Initiate global turtle colonization?')
    term.write('(Y/N) > ')

    if string.upper(read()) ~= 'Y' then
        print('Shutdown...')
        os.shutdown()
        return
    end

    term.clear()
    term.setCursorPos(1, 1)

    print('Beginning...')
    sleep(1)
    for i = 5, 1, -1 do
        print(i)
        sleep(1)
    end
    
    term.clear()
    term.setCursorPos(1, 1)

    initiate()

end


function populateDisk()
    -- This is the most meta function I've ever written
    if not fs.isDir('/disk') then
        error('Disk not inserted')
    end
    local file_contents = fs.open('startup', 'r').readAll()
    s = 'FILE_CONTENTS = [===[' .. file_contents .. ']' .. '===]'
    s = s .. [[
    file = fs.open('/startup', 'w')
    file.write(FILE_CONTENTS)
    file.close()
    shell.run('startup')
    ]]
    file = fs.open('/disk/startup', 'w')
    file.write(s)
    file.close()
end


function initiate()
    local filename = debug.getinfo(2, "S").short_src
    local file = fs.open(filename, 'r')
    if not file then error('File not found somehow...') end

    local file_contents = file.readAll()
    file_contents = file_contents:sub(1, -11) .. 'main()'
    file = fs.open('/startup', 'w')
    file.write(file_contents)
    file.close()
    os.reboot()
end


nameTurtle()
userInit()