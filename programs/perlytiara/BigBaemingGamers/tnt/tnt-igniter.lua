-- TNT --

local SLOT_COUNT = 16

function move()
    while(turtle.detect()) do
        turtle.dig()
    end
    turtle.forward()
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

function getItemIndex(itemName)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == itemName) then
                return slot
            end
        end
    end
end


checkFuel()
turtle.digDown()
turtle.select(getItemIndex("minecraft:tnt"))
turtle.placeDown()
move()
turtle.digDown()
turtle.select(getItemIndex("minecraft:redstone_block"))
turtle.placeDown()

for i = 1, 10, 1 do
    move()
end


