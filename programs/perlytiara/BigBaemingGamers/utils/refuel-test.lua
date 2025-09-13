local SLOT_COUNT = 16

function checkFuel()
    turtle.select(1)
    
    if(turtle.getFuelLevel() < 100) then
        for slot = 1, SLOT_COUNT, 1 do
            print(string.format("Attempting refuel on slot %d", slot))
            turtle.select(slot)
            if(turtle.refuel(1)) then
                return true
            end
        end
    end


end

while(true)
do
    if(not checkFuel()) then
        print("Turtle is out of fuel...")

        break
    end

end
