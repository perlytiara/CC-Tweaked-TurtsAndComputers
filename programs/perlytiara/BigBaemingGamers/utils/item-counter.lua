local SLOT_COUNT = 16


function getCountOfItem(name)
    count = 0
    for i = 1, SLOT_COUNT, 1 do
        d = turtle.getItemDetail()
        if(d ~= nil) then
            if(d['name'] == name) then
                count = count + d['count']
            end
        end
    end

    return count
end

x = getCountOfItem('minecraft:bamboo')
print(x)