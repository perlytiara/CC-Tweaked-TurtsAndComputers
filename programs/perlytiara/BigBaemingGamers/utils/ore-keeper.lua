local SLOT_COUNT = 16

KEEP_ITEMS = {
    "minecraft:diamond",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "thermalfoundation:ore",
    "ic2:resource"
}

function dropItemsFromList()
    print("Purging Inventory...")

    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        local keepItem = false
        if(item ~= nil) then
            for keepItemIndex = 1, #KEEP_ITEMS, 1 do
                if(item["name"] == KEEP_ITEMS[keepItemIndex]) then
                    keepItem = true
                end

                print(item["name"])
                print(KEEP_ITEMS[keepItemIndex])
                print(item["name"] == KEEP_ITEMS[keepItemIndex])

                if(not keepItem) then
                    turtle.select(slot)
                    turtle.dropDown()
                end
            end
        end
    end 
end

dropItemsFromList()