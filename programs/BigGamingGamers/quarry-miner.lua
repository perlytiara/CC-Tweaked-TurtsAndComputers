local SLOT_COUNT = 16
local d = "north"
local width, depth, height = 10, 10, 2

if (#arg == 3) then
    width = tonumber(arg[1])
    depth = tonumber(arg[2])
    height = tonumber(arg[3])
else
    print('None or Malformed Size Given, Defaulting to 10x10x2 up')
end


DROPPED_ITEMS = {
    "minecraft:stone",
    "minecraft:dirt",
    "minecraft:cobblestone",
    "minecraft:sand",
    "minecraft:gravel",
    "minecraft:redstone",
    "minecraft:flint",
    "railcraft:ore_metal",
    "extrautils2:ingredients",
    "minecraft:dye",
    "thaumcraft:nugget",
    "thaumcraft:crystal_essence",
    "thermalfoundation:material",
    "projectred-core:resource_item",
    "thaumcraft:ore_cinnabar",
    "deepresonance:resonating_ore",
    "forestry:apatite"
}
function dropItems()
    print("Purging Inventory...")
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            for filterIndex = 1, #DROPPED_ITEMS, 1 do
                if(item["name"] == DROPPED_ITEMS[filterIndex]) then
                    print("Dropping - " .. item["name"])
                    turtle.select(slot)
                    turtle.dropDown()
                end
            end
        end
    end
end


function getEnderIndex()
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == "enderstorage:ender_storage") then
                return slot
            end
        end
    end
    return nil
end

function manageInventory()
    dropItems()
    index = getEnderIndex()
    if(index ~= nil) then
        turtle.select(index)
        turtle.digUp()      
        turtle.placeUp()  
    end
    -- Chest is now deployed
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] ~= "minecraft:coal_block" and item["name"] ~= "minecraft:coal") then
                turtle.select(slot)
                turtle.dropUp()
            end
        end
    end
    -- Items are now stored

    turtle.digUp()
end

function checkFuel()
    turtle.select(1)
    
    if(turtle.getFuelLevel() < 50) then
        print("Attempting Refuel...")
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel(1)) then
                return true
            end
        end

        return false
    else
        return true
    end
end


function detectAndDig()
    while(turtle.detect()) do
        turtle.dig()
        turtle.digUp()
        turtle.digDown()
    end
end

function forward()
    detectAndDig()
    turtle.forward()
end

function leftTurn()
    turtle.turnLeft()
    detectAndDig()
    turtle.forward()
    turtle.turnLeft()
    detectAndDig()
end


function rightTurn()
    turtle.turnRight()
    detectAndDig()
    turtle.forward()
    turtle.turnRight()
    detectAndDig()
end

function flipDirection()
    if(d == "north") then
        d = "south"
    elseif(d == "south") then
        d = "north"
    elseif(d == "west") then
        d = "east"
    elseif(d == "east") then
        d = "west"
    end
    
end

function turnAround(tier)
    if(tier % 2 == 1) then
        if(d == "north" or d == "east") then
            rightTurn()
        elseif(d == "south" or d == "west") then
            leftTurn()
        end
    else
        if(d == "north" or d == "east") then
            leftTurn()
        elseif(d == "south" or d == "west") then
            rightTurn()
        end
    end
    flipDirection()
end


function riseTier()
    turtle.turnRight()
    turtle.turnRight()
    flipDirection()
    turtle.digUp()
    turtle.up()
end


function start()
    for tier = 1, height, 1 do
        for col = 1, width, 1 do
            for row = 1, depth - 1, 1 do
                if(not checkFuel()) then
                    print("Turtle is out of fuel, Powering Down...")
                    return
                end
                forward()
                print(string.format("Row: %d   Col: %d", row, col))
            end
            if(col ~= width) then
                turnAround(tier)
            end
            manageInventory()
        end
        riseTier()
    end
end

start()



