local SLOT_COUNT = 16

function dropItems()
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            print(item["name"])
        end
    end
end

dropItems()