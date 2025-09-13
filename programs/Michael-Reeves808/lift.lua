-- Update: 4SzF1Sab
-- pastebin get 4SzF1Sab update
-- lift up update


local args = {...}
local SLOT_COUNT = 16


function dropItems(direction)
    if(direction == 'forward') then
        turtle.drop()
    elseif(direction == 'up') then
        turtle.dropUp()
    elseif(direction == 'down') then
        turtle.dropDown()
    elseif(direction == nil) then
        turtle.drop()
    end
    
end

function getFirstItemIndex()
    for i = 1, SLOT_COUNT, 1 do
        turtle.select(i)
        if turtle.getItemDetail() ~= nil then
            return i
        end
    end

    return nil
end

print('Lift Starting in mode: ' .. args[1])
while (true) do
    os.pullEvent('turtle_inventory')
    i = getFirstItemIndex()
    if (i ~= nil) then
        turtle.select(i)
        dropItems(args[1])
        turtle.suckDown()
    end
end