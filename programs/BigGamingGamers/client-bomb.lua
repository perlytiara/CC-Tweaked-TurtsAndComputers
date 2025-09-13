local SLOT_COUNT = 16

local modem = peripheral.wrap("left")
modem.open(100)

local function checkFuel()
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

local function getItemIndex(itemName)
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
local event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")

while(true) do
    checkFuel()
    getItemIndex("minecraft:tnt")

    for i = 1, 2, 1 do
        turtle.forward()
    end

    turtle.placeDown()
    redstone.setOutput("bottom", true)
end