local SLOT_COUNT = 16
local FUEL_CHEST = 15
local TNT_CHEST = 16

local FILL_SLOT_COUNT = 4 


local modem = peripheral.wrap("left")
modem.open(100)

function countItems(itemToCount)
    local itemCount = 0
    for slot = 1, SLOT_COUNT, 1 do
        item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item.name == itemToCount) then
                itemCount = itemCount + turtle.getItemCount(slot)
            end
        end
    end

    return itemCount
end


function checkFuel()
    if(turtle.getFuelLevel() < 100) then
        turtle.select(FUEL_CHEST)
        turtle.digUp()
        turtle.placeUp()
        --Chest is deployed
        
        turtle.suckUp()
    
        while(true) do
            bucketIndex = getItemIndex("minecraft:lava_bucket")
            if(bucketIndex == nil) then
                turtle.suckUp()
                turtle.dropUp()
            else
                turtle.select(bucketIndex)
                turtle.refuel()
                turtle.dropUp()
                turtle.digUp()
                return true
            end
        end
    end
    return true
end



function checkTNT()
    if (countItems("minecraft:tnt") < 64) then
        turtle.select(TNT_CHEST)
        turtle.digUp()
        turtle.placeUp()

        for slot = 1, FILL_SLOT_COUNT, 1 do
            turtle.select(slot)
            turtle.suckUp()
        end

        turtle.select(TNT_CHEST)
        turtle.digUp()
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


print("Waiting for signal")
event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
redstone.setOutput("bottom", true)

while(true) do
    checkFuel()
    checkTNT()

    
    turtle.forward()



    turtle.select(getItemIndex("minecraft:tnt"))
    turtle.placeDown()
	turtle.placeDown()
	turtle.placeDown()
	turtle.placeDown()
	turtle.placeDown()
end