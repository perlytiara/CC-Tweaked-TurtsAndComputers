function getItemIndex(itemName)
    for slot = 1, 16, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == itemName) then
                return slot
            end
        end
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

while(1)
do
    isBlock, data = turtle.inspect()
    
    if(isBlock)
    then
        if (data['state']['age'] == 7)
        then
            turtle.dig()
            succ()
            potatoIndex = getItemIndex("minecraft:potato")
            turtle.select(potatoIndex)
            turtle.place()
            turtle.dropDown(turtle.getItemCount(potatoIndex) - 1)
        end
    else
        succ()
        potatoIndex = getItemIndex("minecraft:potato")
        turtle.place()
    end

    
    if (checkLeft())
    then
        turtle.turnRight()
        turtle.turnRight()
        while(not turtle.detect())
        do
            turtle.forward()
        end
        turtle.turnLeft()
    end
end
    
    
