local TOTAL_SESSION_POTATOES = 0
local SLOT_COUNT = 16

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

function dropPotatoes(potatoIndex)
    -- Drop normal potatoes
    numPotatoes = turtle.getItemCount(potatoIndex) - 1
    
    if numPotatoes > 0 
    then
        turtle.select(potatoIndex)
        turtle.dropDown(numPotatoes)
    end

    -- Drop poisin potatoes
    potatoIndex = getItemIndex("minecraft:poisonous_potato")
    if potatoIndex ~= nil
    then
        turtle.select(potatoIndex)
        turtle.dropDown()
    end

end

function harvestRow()
    isBlock, data = turtle.inspect()
    
    if(isBlock)
    then
        if (data['state']['age'] == 7)
        then
            potatoIndex = getItemIndex("minecraft:potato")
            turtle.select(potatoIndex)
            turtle.dig()
            turtle.place()
            succ()
            
            dropPotatoes(potatoIndex)
            TOTAL_SESSION_POTATOES = TOTAL_SESSION_POTATOES + numPotatoes
        end
    else
        succ()
        potatoIndex = getItemIndex("minecraft:potato")
        turtle.select(potatoIndex)
        canPlace = turtle.place()

        if(not canPlace)
        then
            turtle.turnLeft()
        end
    end

    succ()
end

function isGrown()
    isBlock, data = turtle.inspect()
    
    if(isBlock)
    then
        if (data['state']['age'] == 7)
        then
            return true
        end
    end
    return false
end

function waitForGrowth()
    while(not isGrown())
    do
        sleep(5)
    end
end

function checkLeft()
    turtle.turnLeft()
    if (turtle.detect())
    then
        return true
    end
    turtle.forward()
    turtle.turnRight()
    return false
end


function succ()
    for i = 1, 6, 1
    do
        turtle.suck()
    end
end


print('Beginning Harvest...')

while(1)
do
    harvestRow()
    
    if (checkLeft())
    then
        print(TOTAL_SESSION_POTATOES .. ' potatoes harvested')
        turtle.turnLeft()
        checkFuel()
        waitForGrowth()
    end
end


    