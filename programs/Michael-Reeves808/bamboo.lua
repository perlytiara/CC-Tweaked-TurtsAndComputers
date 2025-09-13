local SLOT_COUNT = 16

function checkFuel()
    turtle.select(1)
 
    if(turtle.getFuelLevel() < 50) then
        print("Attempting Refuel...")
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel()) then
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

while(1) do
    checkFuel()
    turtle.select(getItemIndex('minecraft:baked_potato'))
    turtle.drop(1)
    os.sleep(.5)
    turtle.forward()
end