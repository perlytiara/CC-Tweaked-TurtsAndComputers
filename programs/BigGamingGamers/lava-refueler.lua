local SLOT_COUNT = 16

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


function verifyLava(bucketIndex)
    if(bucketIndex == nil) then
        turtle.dropUp()
        return
    end
end

function checkFuel()
    
    turtle.select(getItemIndex("enderstorage:ender_storage"))
    turtle.digUp()
    turtle.placeUp()
    --Chest is deployed
    
    turtle.suckUp()
    
    while(turtle.getFuelLevel() < 1000) do
        
        bucketIndex = getItemIndex("minecraft:lava_bucket")
        if(bucketIndex == nil) then
            turtle.suckUp()
            turtle.dropUp()
        else
            turtle.select(bucketIndex)
            turtle.refuel()
            turtle.dropUp()
            turtle.digUp()
            break
        end
    end
end

checkFuel()

-- pastebin get 3nMw1mEr test